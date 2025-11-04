import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../controllers/product_controller.dart';
import '../services/category_service.dart';

/// ------------------------------------------------------------
/// PRELOAD SERVICE
/// ------------------------------------------------------------
class PreloadService {
  final ProductController _productController;
  final CategoryService _categoryService = CategoryService();
  
  bool _isPreloading = false;
  bool _isComplete = false;
  String? _error;
  double _progress = 0.0;
  
  PreloadService(this._productController);
  
  bool get isPreloading => _isPreloading;
  bool get isComplete => _isComplete;
  String? get error => _error;
  double get progress => _progress;
  
  /// ------------------------------------------------------------
  /// Preload all data: products, categories, and images
  /// ------------------------------------------------------------
  Future<void> preloadAll(BuildContext context) async {
    if (_isPreloading || _isComplete) {
      if (kDebugMode) {
        debugPrint('ℹ️ Preload already in progress or complete');
      }
      return;
    }
    
    _isPreloading = true;
    _error = null;
    _progress = 0.0;
    
    if (kDebugMode) {
      debugPrint('🚀 Starting preload sequence...');
    }
    
    try {
      // Step 1: Fetch products (25% progress)
      if (kDebugMode) {
        debugPrint('📦 Step 1/4: Fetching products...');
      }
      await _productController.fetchProducts(forceRefresh: true);
      _progress = 0.25;
      
      if (_productController.products.isEmpty) {
        throw Exception('No products were fetched');
      }
      
      if (kDebugMode) {
        debugPrint('✅ Products fetched: ${_productController.products.length}');
      }
      
      // Step 2: Fetch categories (50% progress)
      if (kDebugMode) {
        debugPrint('📁 Step 2/4: Fetching categories...');
      }
      final categories = await _categoryService.fetchCategories();
      _progress = 0.5;
      
      if (kDebugMode) {
        debugPrint('✅ Categories fetched: ${categories.length}');
      }
      
      // Step 3: Preload product images (75% progress)
      if (kDebugMode) {
        debugPrint('🖼️ Step 3/4: Preloading product images...');
      }
      await _preloadProductImages(context);
      _progress = 0.75;
      
      // Step 4: Preload category images (100% progress)
      if (kDebugMode) {
        debugPrint('🖼️ Step 4/4: Preloading category images...');
      }
      await _preloadCategoryImages(context, categories);
      _progress = 1.0;
      
      _isComplete = true;
      
      if (kDebugMode) {
        debugPrint('✅ Preload complete! All data cached and ready.');
      }
    } catch (e, stack) {
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('❌ Preload failed: $e');
        debugPrint(stack.toString());
      }
    } finally {
      _isPreloading = false;
    }
  }
  
  /// ------------------------------------------------------------
  /// Preload all product images
  /// ------------------------------------------------------------
  Future<void> _preloadProductImages(BuildContext context) async {
    final products = _productController.products;
    final imageUrls = products
        .where((p) => p.imageUrl.isNotEmpty)
        .map((p) => p.imageUrl)
        .toSet() // Remove duplicates
        .toList();
    
    if (imageUrls.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ No product images to preload');
      }
      return;
    }
    
    if (kDebugMode) {
      debugPrint('📸 Preloading ${imageUrls.length} unique product images...');
    }
    
    // Preload images in batches to avoid overwhelming the network
    const batchSize = 10;
    for (int i = 0; i < imageUrls.length; i += batchSize) {
      final batch = imageUrls.skip(i).take(batchSize).toList();
      
      await Future.wait(
        batch.map((url) => _preloadImage(context, url)),
        eagerError: false, // Continue even if some images fail
      );
      
      if (kDebugMode && (i + batchSize) % 50 == 0) {
        debugPrint('📸 Progress: ${i + batchSize}/${imageUrls.length} images');
      }
    }
    
    if (kDebugMode) {
      debugPrint('✅ All product images preloaded');
    }
  }
  
  /// ------------------------------------------------------------
  /// Preload category images
  /// ------------------------------------------------------------
  Future<void> _preloadCategoryImages(
    BuildContext context,
    List<Map<String, dynamic>> categories,
  ) async {
    final imageUrls = categories
        .where((cat) => cat['imageUrl'] != null && cat['imageUrl'].toString().isNotEmpty)
        .map((cat) => cat['imageUrl'].toString())
        .toSet() // Remove duplicates
        .toList();
    
    if (imageUrls.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ No category images to preload');
      }
      return;
    }
    
    if (kDebugMode) {
      debugPrint('📸 Preloading ${imageUrls.length} category images...');
    }
    
    await Future.wait(
      imageUrls.map((url) => _preloadImage(context, url)),
      eagerError: false, // Continue even if some images fail
    );
    
    if (kDebugMode) {
      debugPrint('✅ All category images preloaded');
    }
  }
  
  /// ------------------------------------------------------------
  /// Preload a single image
  /// ------------------------------------------------------------

  Future<void> _preloadImage(BuildContext context, String url) async {
    try {
      final imageProvider = NetworkImage(url);
      
      // Precache the image - this loads and decodes it into memory
      // The size parameter helps ensure it's cached at a reasonable size
      await precacheImage(
        imageProvider,
        context,
        size: const Size(800, 800), // Preload at a good size for product images
      );
      
      // Verify the image is actually in cache by trying to resolve it
      // This ensures the image is fully decoded and ready
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);
      
      final completer = Completer<ImageInfo?>();
      late ImageStreamListener listener;
      bool isResolved = false;
      
      listener = ImageStreamListener(
        (ImageInfo imageInfo, bool synchronousCall) {
          if (!isResolved) {
            isResolved = true;
            // Keep a reference to the image to prevent garbage collection
            // The imageInfo contains the decoded image data
            completer.complete(imageInfo);
            imageStream.removeListener(listener);
          }
        },
        onError: (exception, stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(exception, stackTrace);
          }
          imageStream.removeListener(listener);
        },
      );
      
      imageStream.addListener(listener);
      
      // Wait for the image to be fully resolved (with timeout)
      try {
        await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            imageStream.removeListener(listener);
            return null;
          },
        );
      } catch (e) {
        imageStream.removeListener(listener);
        // Silently continue - image might still be in cache from precacheImage
      }
    } catch (e) {
      // Silently fail for individual images - not critical
      if (kDebugMode) {
        debugPrint('⚠️ Failed to preload image: $url - $e');
      }
    }
  }
  
  /// ------------------------------------------------------------
  /// Reset preload state (for testing or retry)
  /// ------------------------------------------------------------
  void reset() {
    _isPreloading = false;
    _isComplete = false;
    _error = null;
    _progress = 0.0;
  }
}

