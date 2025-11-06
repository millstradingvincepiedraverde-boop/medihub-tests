import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/product_controller.dart';
import '../services/category_service.dart';

/// ------------------------------------------------------------
/// PRELOAD SERVICE
/// ------------------------------------------------------------

class PreloadService {
  final ProductController _productController;
  final CategoryService _categoryService = CategoryService();
  
  static const String _lastFetchKey = 'preload_last_fetch_timestamp';
  
  bool _isPreloading = false;
  bool _isComplete = false;
  String? _error;
  double _progress = 0.0;
  Timer? _midnightCheckTimer;
  
  PreloadService(this._productController);
  
  bool get isPreloading => _isPreloading;
  bool get isComplete => _isComplete;
  String? get error => _error;
  double get progress => _progress;
  
  /// ------------------------------------------------------------
  /// Start monitoring for midnight while app is open
  /// ------------------------------------------------------------
  void startMidnightMonitoring() {
    // Cancel any existing timer
    _midnightCheckTimer?.cancel();
    
    // Check every 15 minutes if midnight has passed
    _midnightCheckTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _checkForMidnight(),
    );
    
    if (kDebugMode) {
      debugPrint('🕐 Started midnight monitoring (checks every 15 minutes)');
    }
  }
  
  /// ------------------------------------------------------------
  /// Stop monitoring for midnight
  /// ------------------------------------------------------------
  void stopMidnightMonitoring() {
    _midnightCheckTimer?.cancel();
    _midnightCheckTimer = null;
    
    if (kDebugMode) {
      debugPrint('🛑 Stopped midnight monitoring');
    }
  }
  
  /// ------------------------------------------------------------
  /// Check if midnight has passed and reset state if needed
  /// ------------------------------------------------------------
  Future<void> _checkForMidnight() async {
    try {
      final shouldRefetch = await _shouldRefetch();
      
      if (shouldRefetch && _isComplete) {
        if (kDebugMode) {
          debugPrint('🔄 Midnight detected while app is open - triggering background refresh');
        }
        
        // Reset completion state
        _isComplete = false;
        
        // Trigger a background refresh (data only, no images)
        // This ensures fresh data is available immediately
        await _backgroundRefresh();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error checking for midnight: $e');
      }
    }
  }
  
  /// ------------------------------------------------------------
  /// Background refresh of data (without image preloading)
  /// ------------------------------------------------------------
  Future<void> _backgroundRefresh() async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 Starting background data refresh...');
      }
      
      // Refresh products (force refresh)
      await _productController.fetchProducts(forceRefresh: true);
      
      // Refresh categories (always fresh)
      await _categoryService.fetchCategories();
      
      // Update the last fetch timestamp
      await _saveLastFetchTime();
      
      if (kDebugMode) {
        debugPrint('✅ Background refresh complete - data updated');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Background refresh failed: $e');
      }
      // Don't mark as complete if refresh failed
      // Will retry on next preload
    }
  }
  
  /// ------------------------------------------------------------
  /// Check if we need to refetch (past midnight since last fetch)
  /// ------------------------------------------------------------
  Future<bool> _shouldRefetch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchTimestamp = prefs.getInt(_lastFetchKey);
      
      if (lastFetchTimestamp == null) {
        // Never fetched before, should fetch
        return true;
      }
      
      final lastFetchDate = DateTime.fromMillisecondsSinceEpoch(lastFetchTimestamp);
      final now = DateTime.now();
      
      // Check if we've crossed midnight since last fetch
      // Compare dates (year, month, day) to see if it's a new day
      final lastFetchDay = DateTime(lastFetchDate.year, lastFetchDate.month, lastFetchDate.day);
      final today = DateTime(now.year, now.month, now.day);
      
      final shouldRefetch = today.isAfter(lastFetchDay);
      
      if (kDebugMode && shouldRefetch) {
        debugPrint('🔄 New day detected - will refetch data');
        debugPrint('   Last fetch: $lastFetchDay');
        debugPrint('   Today: $today');
      }
      
      return shouldRefetch;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error checking refetch status: $e');
      }
      // On error, assume we should refetch to be safe
      return true;
    }
  }
  
  /// ------------------------------------------------------------
  /// Save the current timestamp as last fetch time
  /// ------------------------------------------------------------
  Future<void> _saveLastFetchTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      await prefs.setInt(_lastFetchKey, now.millisecondsSinceEpoch);
      
      if (kDebugMode) {
        debugPrint('💾 Saved last fetch timestamp: $now');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error saving last fetch timestamp: $e');
      }
    }
  }
  
  /// ------------------------------------------------------------
  /// Preload all data: products, categories, and images
  /// ------------------------------------------------------------

  Future<void> preloadAll(BuildContext context) async {
    if (_isPreloading) {
      if (kDebugMode) {
        debugPrint('ℹ️ Preload already in progress');
      }
      return;
    }
    
    // Check if we need to refetch (past midnight)
    final shouldRefetch = await _shouldRefetch();
    
    // If already complete and not a new day, skip
    if (_isComplete && !shouldRefetch) {
      if (kDebugMode) {
        debugPrint('ℹ️ Preload already complete and data is fresh');
      }
      return;
    }
    
    // Reset completion state if it's a new day
    if (shouldRefetch) {
      _isComplete = false;
    }
    
    _isPreloading = true;
    _error = null;
    _progress = 0.0;
    
    if (kDebugMode) {
      debugPrint('🚀 Starting preload sequence...');
      if (shouldRefetch) {
        debugPrint('🔄 Refreshing data (new day or first run)');
      }
    }
    
    try {
      // Step 1: Fetch products (25% progress)
      // Force refresh if it's a new day
      if (kDebugMode) {
        debugPrint('📦 Step 1/4: Fetching products...');
      }
      await _productController.fetchProducts(forceRefresh: shouldRefetch);
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
      
      // Save the fetch timestamp
      await _saveLastFetchTime();
      
      // Start monitoring for midnight while app is open
      startMidnightMonitoring();
      
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
    stopMidnightMonitoring();
  }
  
  /// ------------------------------------------------------------
  /// Dispose resources
  /// ------------------------------------------------------------
  void dispose() {
    stopMidnightMonitoring();
  }
}

