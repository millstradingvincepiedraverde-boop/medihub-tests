import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medihub_tests/screens/catalog/product_detail_screen.dart';
import 'package:medihub_tests/utils/catalog/breadcrumb_widget.dart';
import 'package:medihub_tests/utils/catalog/category_sidebar.dart';
import 'package:medihub_tests/utils/catalog/inactivity_dialog.dart';
import 'package:medihub_tests/utils/catalog/mobile_category_chips.dart';
import 'package:medihub_tests/utils/catalog/product_grid_view.dart';
import 'package:medihub_tests/utils/catalog/search_filter_bar.dart';
import 'package:provider/provider.dart';
import 'package:medihub_tests/controllers/product_controller.dart';
import 'package:medihub_tests/screens/kiosk-main.dart';
import 'package:medihub_tests/widgets/footer_widget.dart';
import 'package:medihub_tests/models/product.dart';
import 'package:medihub_tests/services/order_service.dart';
import 'package:medihub_tests/widgets/bottom_cart_button.dart';
import 'package:medihub_tests/widgets/hero_banner.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final OrderService _orderService = OrderService();

  static const double _kTabletBreakpoint = 800.0;
  static const Duration _inactivityTimeout = Duration(seconds: 120);

  ProductCategory? _selectedCategory;
  dynamic _selectedSubType;
  String _searchQuery = '';

  late final TextEditingController _searchController;
  List<String> _breadcrumbPath = ['Home'];
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    Future.microtask(() {
      context.read<ProductController>().fetchProducts(forceRefresh: true);
      _startInactivityTimer();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cancelInactivityTimer();
    super.dispose();
  }

  // ============================================================================
  // TIMER LOGIC
  // ============================================================================

  void _startInactivityTimer() {
    _cancelInactivityTimer();
    print('⏱️ Timer started (${_inactivityTimeout.inSeconds}s)');
    _inactivityTimer = Timer(_inactivityTimeout, _showInactivityDialog);
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  void _onUserInteraction() {
    print('👆 Interaction detected');
    _resetInactivityTimer();
  }

  void _showInactivityDialog() {
    if (!mounted) return;
    print('⚠️ Timeout reached, showing dialog');

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) {
        return InactivityDialog(
          onExtendSession: _resetInactivityTimer,
          onTimeout: _navigateToKiosk,
        );
      },
    );
  }

  void _navigateToKiosk() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const KioskMain()),
      (route) => false,
    );
  }

  // ============================================================================
  // PRODUCT FILTERING
  // ============================================================================

  List<Product> get _filteredProducts {
    final productController = context.watch<ProductController>();

    var products = _selectedCategory == null
        ? productController.products
        : productController.getProductsByCategory(_selectedCategory!);

    if (_selectedSubType != null) {
      products = products.where((p) => p.subType == _selectedSubType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final lowerCaseQuery = _searchQuery.toLowerCase();
      products = products.where((product) {
        return product.name.toLowerCase().contains(lowerCaseQuery) ||
            product.description.toLowerCase().contains(lowerCaseQuery) ||
            product.colorName.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }

    return products;
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  String _getSubTypeDisplayName(dynamic subType) {
    if (subType == null) return 'All';

    final tempProduct = Product(
      id: '',
      sku: '',
      name: '',
      description: '',
      category: _selectedCategory!,
      subType: subType,
      price: 0,
      imageUrl: '',
      features: [],
      stockQuantity: 0,
      color: Colors.grey,
      colorName: '',
    );
    return tempProduct.subTypeDisplayName;
  }

  ProductCategory? _getCategoryFromDisplayName(String displayName) {
    for (var category in ProductCategory.values) {
      final tempProduct = Product(
        id: '',
        name: '',
        sku: '',
        description: '',
        category: category,
        subType: '',
        price: 0,
        imageUrl: '',
        features: [],
        stockQuantity: 0,
        color: Colors.grey,
        colorName: '',
      );
      if (tempProduct.categoryDisplayName == displayName) {
        return category;
      }
    }
    return null;
  }

  // ============================================================================
  // NAVIGATION LOGIC
  // ============================================================================

  void _updateBreadcrumbPath({ProductCategory? category, dynamic subType}) {
    setState(() {
      _selectedCategory = category;
      _selectedSubType = subType;

      _breadcrumbPath = ['Home'];
      if (category != null) {
        final tempProduct = Product(
          id: '',
          sku: '',
          name: '',
          description: '',
          category: category,
          subType: '',
          price: 0,
          imageUrl: '',
          features: [],
          stockQuantity: 0,
          color: Colors.grey,
          colorName: '',
        );
        _breadcrumbPath.add(tempProduct.categoryDisplayName);

        if (subType != null) {
          _breadcrumbPath.add(_getSubTypeDisplayName(subType));
        }
      }

      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _handleBreadcrumbTap(int index) {
    setState(() {
      if (index == 0) {
        _updateBreadcrumbPath(category: null, subType: null);
      } else if (index == 1) {
        final categoryName = _breadcrumbPath[1];
        final category = _getCategoryFromDisplayName(categoryName);

        if (category != null) {
          _updateBreadcrumbPath(category: category, subType: null);
        } else {
          _updateBreadcrumbPath(category: null, subType: null);
        }
      }
    });
  }

  // ============================================================================
  // PRODUCT TAP HANDLER
  // ============================================================================

  void _handleProductTap(Product product) {
    _cancelInactivityTimer();

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final slideTween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: Curves.easeOutCubic));

          return FadeTransition(
            opacity: animation,
            child: Stack(
              children: [
                // Tap outside to dismiss
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.black.withOpacity(0.4)),
                  ),
                ),

                // Bottom Sheet
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SlideTransition(
                    position: animation.drive(slideTween),
                    child: FractionallySizedBox(
                      widthFactor: 1.0,
                      heightFactor: 0.85,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: ProductDetailScreen(product: product),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            child,
      ),
    ).then((_) {
      _resetInactivityTimer();
    });
  }

  // ============================================================================
  // MAIN PRODUCT AREA
  // ============================================================================

  Widget _buildMainProductArea(double screenWidth) {
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 3; // Desktop
    } else if (screenWidth >= _kTabletBreakpoint) {
      crossAxisCount = 2; // Tablet
    } else {
      crossAxisCount = 2; // Mobile
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInactivityTimer();
    });

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserInteraction(),
      onPointerMove: (_) => _onUserInteraction(),
      onPointerHover: (_) => _onUserInteraction(),
      child: Column(
        children: [
          // Breadcrumb
          BreadcrumbWidget(
            breadcrumbPath: _breadcrumbPath,
            onBreadcrumbTap: _handleBreadcrumbTap,
          ),

          // Search & Filter Bar
          SearchFilterBar(
            searchController: _searchController,
            searchQuery: _searchQuery,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onClearSearch: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
            },
            showSubcategoryFilter: _selectedCategory != null,
            selectedSubTypeDisplay: _selectedSubType == null
                ? null
                : _getSubTypeDisplayName(_selectedSubType),
            onFilterPressed: () {
              // TODO: Implement subcategory filter
            },
          ),

          // Hero Banner (only on home view)
          if (_selectedCategory == null && _searchQuery.isEmpty)
            HeroBanner(screenWidth: screenWidth),

          // Header placeholder for sorting controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),

          // Product Grid / Empty State
          Expanded(
            child: ProductGridView(
              products: _filteredProducts,
              crossAxisCount: crossAxisCount,
              onProductTap: _handleProductTap,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= _kTabletBreakpoint;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserInteraction(),
      onPointerMove: (_) => _onUserInteraction(),
      onPointerHover: (_) => _onUserInteraction(),
      child: Scaffold(
        body: isLargeScreen
            ? Row(
                // Desktop / Tablet Layout
                children: [
                  CategorySidebar(
                    selectedCategory: _selectedCategory,
                    selectedSubType: _selectedSubType,
                    onCategorySelected: (category) {
                      _updateBreadcrumbPath(category: category, subType: null);
                    },
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: _buildMainProductArea(screenWidth)),
                ],
              )
            : Column(
                // Mobile Layout
                children: [
                  MobileCategoryChips(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      _updateBreadcrumbPath(category: category, subType: null);
                    },
                  ),
                  Expanded(child: _buildMainProductArea(screenWidth)),
                ],
              ),

        // Bottom area with cart button and footer
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomCartButton(key: ValueKey(_orderService.cartItemCount)),
            const FooterWidget(),
          ],
        ),
      ),
    );
  }
}
