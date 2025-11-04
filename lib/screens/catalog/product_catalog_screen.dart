import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medihub_tests/screens/catalog/product_detail_screen.dart';
import 'package:medihub_tests/utils/catalog/breadcrumb_widget.dart';
import 'package:medihub_tests/utils/catalog/category_sidebar.dart';
import 'package:medihub_tests/utils/catalog/inactivity_dialog.dart';
import 'package:medihub_tests/utils/catalog/mobile_category_chips.dart';
import 'package:medihub_tests/utils/catalog/product_grid_view.dart';
import 'package:medihub_tests/utils/catalog/search_filter_bar.dart';
import 'package:medihub_tests/widgets/homepage/most_popular_section.dart';
import 'package:medihub_tests/widgets/homepage/qr_code_banner.dart';
import 'package:medihub_tests/widgets/homepage/top_categories_section.dart';
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

  void logDebug(String message) {
    debugPrint('🐞 [CATALOG] $message', wrapWidth: 1024);
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedCategory = null;
    _selectedSubType = null;
    _searchQuery = '';
    logDebug(
      '🟢 initState → category: $_selectedCategory (home view expected)',
    );

    Future.microtask(() {
      if (mounted) {
        // Use cached data - products should already be loaded from splash screen
        context.read<ProductController>().fetchProducts(forceRefresh: false);
        _startInactivityTimer();
      }
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
    logDebug('⏱️ Timer started (${_inactivityTimeout.inSeconds}s)');
    _inactivityTimer = Timer(_inactivityTimeout, _showInactivityDialog);
  }

  void _cancelInactivityTimer() => _inactivityTimer?.cancel();

  void _resetInactivityTimer() {
    logDebug('🔄 Reset inactivity timer');
    _startInactivityTimer();
  }

  void _onUserInteraction() {
    logDebug('👆 User interaction detected');
    _resetInactivityTimer();
  }

  void _showInactivityDialog() {
    if (!mounted) return;
    logDebug('⚠️ Timeout reached → showing inactivity dialog');

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
    logDebug('🏠 Navigating back to kiosk main');
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
    logDebug('🔍 Filtering → category: $_selectedCategory');
    final productController = context.watch<ProductController>();
    var products = _selectedCategory == null
        ? productController.products
        : productController.getProductsByCategory(_selectedCategory!);

    if (_selectedSubType != null) {
      products = products.where((p) => p.subType == _selectedSubType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.colorName.toLowerCase().contains(query);
      }).toList();
    }

    logDebug('📦 Filtered products count: ${products.length}');
    return products;
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  String _getSubTypeDisplayName(dynamic subType) {
    if (subType == null) return 'All';
    final temp = Product(
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
    return temp.subTypeDisplayName;
  }

  ProductCategory? _getCategoryFromDisplayName(String displayName) {
    for (var category in ProductCategory.values) {
      final temp = Product(
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
      if (temp.categoryDisplayName == displayName) return category;
    }
    return null;
  }

  // ============================================================================
  // NAVIGATION
  // ============================================================================

  void _updateBreadcrumbPath({ProductCategory? category, dynamic subType}) {
    logDebug(
      '🧭 Updating breadcrumb → category: $category | subType: $subType',
    );

    setState(() {
      _selectedCategory = category;
      _selectedSubType = subType;

      _breadcrumbPath = ['Home'];
      if (category != null) {
        final temp = Product(
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
        _breadcrumbPath.add(temp.categoryDisplayName);

        if (subType != null) {
          _breadcrumbPath.add(_getSubTypeDisplayName(subType));
        }
      }

      _searchQuery = '';
      _searchController.clear();
    });

    logDebug('✅ Updated → _selectedCategory: $_selectedCategory');
  }

  void _handleBreadcrumbTap(int index) {
    logDebug('🧩 Breadcrumb tapped → index: $index');
    if (index == 0) {
      _updateBreadcrumbPath(category: null, subType: null);
    } else if (index == 1) {
      final catName = _breadcrumbPath[1];
      final cat = _getCategoryFromDisplayName(catName);
      _updateBreadcrumbPath(category: cat, subType: null);
    }
  }

  // ============================================================================
  // PRODUCT TAP
  // ============================================================================

  void _handleProductTap(Product product) {
    _cancelInactivityTimer();
    logDebug('🛒 Product tapped: ${product.name}');

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, _) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: Curves.easeOutCubic));

          return FadeTransition(
            opacity: animation,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(color: Colors.black.withOpacity(0.4)),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SlideTransition(
                    position: animation.drive(tween),
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
        transitionsBuilder: (context, animation, _, child) => child,
      ),
    ).then((_) => _resetInactivityTimer());
  }

  // ============================================================================
  // VIEWS
  // ============================================================================

  Widget _buildMainProductArea(double screenWidth) {
    final isHomeView = _selectedCategory == null && _searchQuery.isEmpty;
    return isHomeView ? _buildHomescreenView() : _buildCatalogView(screenWidth);
  }

  Widget _buildHomescreenView() {
    final controller = context.watch<ProductController>();
    return SingleChildScrollView(
      key: const ValueKey('homescreen'),
      child: Container(
        color: Colors.grey.shade400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MostPopularSection(
              products: controller.products,
              onProductTap: _handleProductTap,
            ),
            TopCategoriesSection(
              onCategoryTap: (category) {
                logDebug('🖱️ Top category tapped: $category');
                _updateBreadcrumbPath(category: category, subType: null);
              },
            ),
            const QRCodeBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogView(double screenWidth) {
    int crossAxisCount = screenWidth >= 1200
        ? 3
        : screenWidth >= _kTabletBreakpoint
        ? 2
        : 2;

    return Container(
      color: Colors.grey.shade100,
      child: Column(
        key: const ValueKey('catalogview'),
        children: [
          BreadcrumbWidget(
            breadcrumbPath: _breadcrumbPath,
            onBreadcrumbTap: _handleBreadcrumbTap,
          ),
          SearchFilterBar(
            searchController: _searchController,
            searchQuery: _searchQuery,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
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
            onFilterPressed: () {},
          ),
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
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLargeScreen = width >= _kTabletBreakpoint;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserInteraction(),
      onPointerMove: (_) => _onUserInteraction(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade400, // 🟢 Global background
        body: isLargeScreen
            ? Row(
                children: [
                  CategorySidebar(
                    selectedCategory: _selectedCategory,
                    selectedSubType: _selectedSubType,
                    onCategorySelected: (category) => _updateBreadcrumbPath(
                      category: category,
                      subType: null,
                    ),
                  ),
                  if (_selectedCategory == null)
                    const VerticalDivider(width: 1, color: Color(0xFFE0E0E0)),
                  Expanded(
                    child: Container(
                      color: Colors.grey.shade400,
                      child: _buildMainProductArea(width),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  MobileCategoryChips(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) => _updateBreadcrumbPath(
                      category: category,
                      subType: null,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey.shade400,
                      child: _buildMainProductArea(width),
                    ),
                  ),
                ],
              ),
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
