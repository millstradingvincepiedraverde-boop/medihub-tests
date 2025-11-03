import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

/// ------------------------------------------------------------
/// PRODUCT CONTROLLER (MVC / MVVM PATTERN)
/// ------------------------------------------------------------
/// Handles fetching, caching, filtering, and state management
/// for product data retrieved from the API.
/// ------------------------------------------------------------
class ProductController extends ChangeNotifier {
  final ProductService _productService = ProductService();

  /// Internal state
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Public getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// ------------------------------------------------------------
  /// Fetch all products from the API
  /// ------------------------------------------------------------
  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (_products.isNotEmpty && !forceRefresh) {
      if (kDebugMode) {
        debugPrint("ℹ️ Using cached products: ${_products.length}");
      }
      return;
    }

    _setLoading(true);

    try {
      final fetched = await _productService.fetchProducts();

      if (fetched.isEmpty) {
        _errorMessage = "No products were found from API.";
        if (kDebugMode) debugPrint("⚠️ Sanity returned an empty product list.");
      } else {
        _products = fetched.cast<Product>();
        _errorMessage = null;

        if (kDebugMode) {
          debugPrint("✅ Products fetched successfully: ${_products.length}");
          for (final product in _products.take(5)) {
            debugPrint("🛒 ${product.name} — ${product.sku}");
          }
          if (_products.length > 5) {
            debugPrint("...and ${_products.length - 5} more products.");
          }
        }
      }
    } catch (e, stack) {
      _errorMessage = '❌ Failed to fetch products: $e';
      if (kDebugMode) {
        debugPrint(_errorMessage);
        debugPrint(stack.toString());
      }
    }

    _setLoading(false);
  }

  List<Product> filteredProducts({
    ProductCategory? category,
    String searchQuery = '',
  }) {
    final all = products; // assuming `products` is your loaded list of Product

    return all.where((product) {
      final matchesCategory = category == null || product.category == category;
      final matchesSearch =
          searchQuery.isEmpty ||
          product.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// ------------------------------------------------------------
  /// Filter products by category
  /// ------------------------------------------------------------
  List<Product> getProductsByCategory(ProductCategory category) {
    return _products.where((p) => p.category == category).toList();
  }

  /// ------------------------------------------------------------
  /// Search products by name, description, or color
  /// ------------------------------------------------------------
  List<Product> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return _products.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.description.toLowerCase().contains(lowerQuery) ||
          p.colorName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// ------------------------------------------------------------
  /// Get single product by SKU or ID
  /// ------------------------------------------------------------
  Product? getProductBySku(String sku) {
    try {
      return _products.firstWhere((p) => p.sku == sku);
    } catch (_) {
      return null;
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// ------------------------------------------------------------
  /// Private helper for setting loading state
  /// ------------------------------------------------------------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// ------------------------------------------------------------
  /// Optional: Clear cached products
  /// ------------------------------------------------------------
  void clearCache() {
    _products = [];
    _errorMessage = null;
    notifyListeners();
  }
}
