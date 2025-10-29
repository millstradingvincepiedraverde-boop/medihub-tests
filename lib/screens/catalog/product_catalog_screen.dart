import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medihub_tests/controllers/product_controller.dart';
import 'package:medihub_tests/screens/kiosk-main.dart';
import 'package:medihub_tests/widgets/footer_widget.dart';
import '../../constants/app_constants.dart';
import '../../models/product.dart';
import '../../services/order_service.dart';
import '../../widgets/product_card.dart';
// import '../../utils/snackbar_helper.dart';
// import '../cart/cart_screen.dart';
import 'product_detail_screen.dart';
import '../../widgets/bottom_cart_button.dart';
import 'package:provider/provider.dart';
import 'package:medihub_tests/widgets/hero_banner.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final OrderService _orderService = OrderService();

  static const double _kTabletBreakpoint = 800.0;

  static const Duration _inactivityTimeout = Duration(
    seconds: 120,
  ); // idle timeout
  static const Duration _dialogAutoClose = Duration(
    seconds: 30,
  ); // auto-redirect delay

  ProductCategory? _selectedCategory;
  dynamic _selectedSubType;

  String _searchQuery = '';

  late final TextEditingController _searchController;

  List<String> _breadcrumbPath = ['Home'];

  Timer? _inactivityTimer;
  Timer? _dialogTimer; // to auto close dialog

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();

    // ✅ Also fetch your products here if not already done
    Future.microtask(() {
      context.read<ProductController>().fetchProducts(forceRefresh: true);

      _startInactivityTimer();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cancelInactivityTimer();
    _dialogTimer?.cancel();
    super.dispose();
  }

  // 🕒 TIMER LOGIC
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
    int countdown = 30;
    _dialogTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) {
        StateSetter? localSetState; // <-- nullable instead of late

        _dialogTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          if (countdown <= 1) {
            timer.cancel();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            _navigateToKiosk();
          } else {
            // Only call if initialized
            if (localSetState != null) {
              localSetState!(() {
                countdown--;
              });
            }
          }
        });

        return StatefulBuilder(
          builder: (context, setState) {
            localSetState = setState;

            return Center(
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () {
                          _dialogTimer?.cancel();
                          Navigator.of(context).pop();
                          _resetInactivityTimer();
                        },
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          "We’ve noticed an inactivity",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            decoration: TextDecoration
                                .none, // ⬅️ prevents yellow underline
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Closing this session in $countdown seconds...",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            decoration: TextDecoration
                                .none, // ⬅️ prevents yellow underline
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              _dialogTimer?.cancel();
                              Navigator.of(context).pop();
                              _resetInactivityTimer();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A306D),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Extend session",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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

  List<Product> get _filteredProducts {
    final productController = context.watch<ProductController>();

    // Start with all products or those filtered by category
    var products = _selectedCategory == null
        ? productController.products
        : productController.getProductsByCategory(_selectedCategory!);

    // Filter by subtype if selected
    if (_selectedSubType != null) {
      products = products.where((p) => p.subType == _selectedSubType).toList();
    }

    // Apply search query if not empty
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

  // List<dynamic> _getSubTypesForCategory(ProductCategory category) {
  //   switch (category) {
  //     case ProductCategory.wheelchairs:
  //       // Assuming WheelchairType is imported or globally available
  //       return WheelchairType.values;
  //     case ProductCategory.mobilityScooters:
  //       return MobilityScooterType.values;
  //     case ProductCategory.dailyLivingAids:
  //       return DailyLivingAidType.values;
  //     case ProductCategory.homeHealthCare:
  //       return HomeHealthCareType.values;
  //   }
  // }

  // --- FIX: SAFE LOOKUP HELPER FUNCTION ---
  ProductCategory? _getCategoryFromDisplayName(String displayName) {
    for (var category in ProductCategory.values) {
      // Create a temporary product to check its display name
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
    // Returns null if no matching category is found (prevents StateError)
    return null;
  }
  // ----------------------------------------

  // 2. NEW NAVIGATION LOGIC
  void _updateBreadcrumbPath({ProductCategory? category, dynamic subType}) {
    setState(() {
      _selectedCategory = category;
      _selectedSubType = subType;

      _breadcrumbPath = ['Home'];
      if (category != null) {
        // Need a temporary product to get the display name for the category
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
      // CRITICAL: Clear search when navigating categories/subtypes
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _handleBreadcrumbTap(int index) {
    setState(() {
      // 0: Home (All Products)
      if (index == 0) {
        _updateBreadcrumbPath(category: null, subType: null);
      }
      // 1: Category (e.g., Wheelchairs)
      else if (index == 1) {
        final categoryName = _breadcrumbPath[1];

        // *** FIX: Use the safe lookup function now ***
        final category = _getCategoryFromDisplayName(categoryName);

        // Only update if a valid category was found
        if (category != null) {
          _updateBreadcrumbPath(category: category, subType: null);
        } else {
          // Fallback to Home if lookup fails unexpectedly
          _updateBreadcrumbPath(category: null, subType: null);
        }
      }
      // Index 2 (SubType) is handled via the subcategory filter button logic
    });
  }

  // 3. NEW BREADCRUMB WIDGET
  Widget _buildBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: List.generate(_breadcrumbPath.length, (index) {
          final label = _breadcrumbPath[index];
          final isLast = index == _breadcrumbPath.length - 1;

          // Create the individual breadcrumb tile
          Widget breadcrumbTile = GestureDetector(
            onTap: isLast ? null : () => _handleBreadcrumbTap(index),
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                  color: isLast
                      ? const Color(0xFF4A306D)
                      : Colors.grey.shade600,
                  decoration: isLast
                      ? TextDecoration.none
                      : TextDecoration.underline,
                  decorationColor: Colors.grey.shade400,
                ),
              ),
            ),
          );

          // Add the separator, unless it's the last item
          if (!isLast) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                breadcrumbTile,
                // *** CHANGE: Replaced Icon with a Text widget for '>' ***
                const Text(
                  ' > ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          }

          return breadcrumbTile;
        }),
      ),
    );
  }

  // NEW: Search and Filter Bar Widget
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 1. Search Field
          Expanded(
            child: TextField(
              // FIX 3: Use the persistent controller
              controller: _searchController,

              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,

              decoration: InputDecoration(
                hintText: 'Search products by name or description...',
                prefixIcon: const Icon(Icons.search),
                // Clear button
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            // CRITICAL: Update the controller's text when clearing the search
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey.shade100,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
              ),
              onChanged: (value) {
                // Update the state variable on every change
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          const SizedBox(width: 16),

          // 2. Subcategory Filter Button
          if (_selectedCategory != null)
            TextButton.icon(
              icon: const Icon(Icons.filter_list),
              label: Text(
                _selectedSubType == null
                    ? 'All Types'
                    : _getSubTypeDisplayName(_selectedSubType),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A306D), // text color
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A306D), // 💡 icon/text color
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // _showSubcategoryFilter(context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMainProductArea(double screenWidth) {
    // Determine crossAxisCount based on screen width
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 3; // Desktop
    } else if (screenWidth >= _kTabletBreakpoint) {
      crossAxisCount = 2; // Tablet
    } else {
      crossAxisCount = 2; // Mobile
    }

    // Detect content layout type
    final bool isContentNarrow = screenWidth >= _kTabletBreakpoint;

    // 🧠 Always start/reset inactivity timer when this widget rebuilds
    // (especially when products or search results change)
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
          // 🧭 Breadcrumb
          _buildBreadcrumb(),

          _buildSearchAndFilterBar(),
          // 🏞 Hero Banner (only on home view)
          if (_selectedCategory == null && _searchQuery.isEmpty)
            HeroBanner(screenWidth: screenWidth),
          // 🔍 Search & Filter Bar (always visible, even when 1 product)
          // 🔲 Optional Header placeholder for sorting controls
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
              children: [
                // reserved for future UI controls
              ],
            ),
          ),

          // 🛒 Product Grid / Empty State
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          // 🧭 Stop timer while viewing product detail
                          _cancelInactivityTimer();

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              transitionDuration: const Duration(
                                milliseconds: 450,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                    const begin = Offset(0.0, 1.0);
                                    const end = Offset.zero;
                                    final slideTween =
                                        Tween(begin: begin, end: end).chain(
                                          CurveTween(
                                            curve: Curves.easeOutCubic,
                                          ),
                                        );

                                    return FadeTransition(
                                      opacity: animation,
                                      child: Stack(
                                        children: [
                                          // Tap outside to dismiss
                                          Positioned.fill(
                                            child: GestureDetector(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              behavior: HitTestBehavior.opaque,
                                              child: Container(
                                                color: Colors.black.withOpacity(
                                                  0.4,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Bottom Sheet
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: SlideTransition(
                                              position: animation.drive(
                                                slideTween,
                                              ),
                                              child: FractionallySizedBox(
                                                widthFactor: 1.0,
                                                heightFactor: 0.85,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          20,
                                                        ),
                                                      ),
                                                  child: ProductDetailScreen(
                                                    product: product,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) => child,
                            ),
                          ).then((_) {
                            // 🕒 Restart timer once user returns
                            _resetInactivityTimer();
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  //Test
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= _kTabletBreakpoint;

    return Listener(
      behavior: HitTestBehavior.translucent,
      // 🧠 Detect all user interactions (tap, scroll, drag, etc.)
      onPointerDown: (_) => _onUserInteraction(),
      onPointerMove: (_) => _onUserInteraction(),
      onPointerHover: (_) => _onUserInteraction(),
      child: Scaffold(
        body: isLargeScreen
            ? Row(
                // === Desktop / Tablet Layout ===
                children: [
                  _buildSidebar(),
                  const VerticalDivider(width: 1),
                  Expanded(child: _buildMainProductArea(screenWidth)),
                ],
              )
            : Column(
                // === Mobile Layout ===
                children: [
                  _buildMobileCategoryChips(),
                  Expanded(child: _buildMainProductArea(screenWidth)),
                ],
              ),

        // === Bottom area with cart button and footer ===
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomCartButton(key: ValueKey(_orderService.cartItemCount)),
            const FooterWidget(), // responsive footer
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildMobileCategoryChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade50,
      height: 60, // Fixed height for horizontal scroll view
      child: ScrollConfiguration(
        // Use ScrollConfiguration to hide the scrollbar
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // All Products Chip
            _buildCategoryChip(
              label: 'All Products',
              isSelected: _selectedCategory == null,
              onTap: () => _updateBreadcrumbPath(category: null, subType: null),
            ),
            const SizedBox(width: 8),

            // Other Category Chips
            ...ProductCategory.values.map((category) {
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
              return Row(
                children: [
                  _buildCategoryChip(
                    label: tempProduct.categoryDisplayName,
                    isSelected: _selectedCategory == category,
                    onTap: () => _updateBreadcrumbPath(
                      category: category,
                      subType: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // ADJUSTED: Increased font size and padding for larger touch target
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 15, // Slightly larger font
        ),
      ),
      avatar: isSelected
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
      backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25), // More rounded
        side: BorderSide(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
        ),
      ),
      onPressed: onTap,
      elevation: 2, // More prominent
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ), // Increased padding
    );
  }

  Widget _buildCategoryTile({
    required String label,
    String? imageUrl,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
  }) {
    final Color primaryColor = const Color.fromARGB(255, 71, 3, 88);

    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
      // ⬆️ Removed right padding to let selected box align flush to the right edge
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Highlight background that expands fully to the right
            Positioned.fill(
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF3F1F6)
                      : Colors.transparent,
                ),
              ),
            ),

            // Actual content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  // Circular image thumbnail
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 238, 238, 238),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? (imageUrl.startsWith('http')
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey.shade400,
                                        size: 36,
                                      ),
                                )
                              : Image.asset(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey.shade400,
                                        size: 36,
                                      ),
                                ))
                        : Icon(
                            Icons.category,
                            color: Colors.grey.shade400,
                            size: 36,
                          ),
                  ),
                  const SizedBox(width: 20),

                  // Label and item count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        if (!isSelected)
                          Text(
                            '$count items',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final Color primaryColor = const Color(0xFF4A306D); // updated color #4A306D

    return Container(
      width: 320, // Slightly wider for kiosk layout
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏷️ Logo Header
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white),
            child: SvgPicture.asset(
              'assets/images/medihub-logo.svg',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),

          // 📋 Category List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Divider(
                    height: 1,
                    color: Color.fromARGB(255, 230, 230, 230),
                  ),
                ),

                // 🧩 Dynamic Categories
                ...ProductCategory.values.map((category) {
                  final productController = context.watch<ProductController>();
                  final products = productController.getProductsByCategory(
                    category,
                  );
                  final count = products.length;

                  final imageUrl = products.isNotEmpty
                      ? products.first.imageUrl
                      : '';

                  // Temporary product for readable category display name
                  final tempProduct = Product(
                    id: '',
                    sku: '',
                    name: '',
                    description: '',
                    category: category,
                    subType: '',
                    price: 0,
                    imageUrl: imageUrl,
                    features: [],
                    stockQuantity: 0,
                    color: primaryColor,
                    colorName: '',
                  );

                  return _buildCategoryTile(
                    label: tempProduct.categoryDisplayName,
                    imageUrl: imageUrl,
                    isSelected:
                        _selectedCategory == category &&
                        _selectedSubType == null,
                    count: count,
                    onTap: () {
                      _updateBreadcrumbPath(category: category, subType: null);
                    },
                  );
                }).toList(),
              ],
            ),
          ),

          // 💬 Support Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.contact_support_outlined,
                  color: primaryColor,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'Need Help?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                Column(
                  children: [
                    Text(
                      AppConstants.supportEmail,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      AppConstants.supportPhone,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // void _showSubcategoryFilter(BuildContext context) {
  //   if (_selectedCategory == null) return;

  //   final subTypes = _getSubTypesForCategory(_selectedCategory!);

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Center(
  //         child: Material(
  //           color: Colors.transparent,
  //           child: Container(
  //             width: MediaQuery.of(context).size.width * 0.85,
  //             constraints: const BoxConstraints(maxWidth: 480),
  //             padding: const EdgeInsets.all(24),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(20),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black26,
  //                   blurRadius: 20,
  //                   offset: const Offset(0, 8),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // ✳️ Title Row with Close Button
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       'Filter by Type',
  //                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     IconButton(
  //                       icon: const Icon(Icons.close, color: Colors.black54),
  //                       onPressed: () => Navigator.pop(context),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 20),

  //                 // ✳️ Subtype Grid (2 columns)
  //                 SizedBox(
  //                   height: 300,
  //                   child: GridView.count(
  //                     crossAxisCount: 2,
  //                     mainAxisSpacing: 12,
  //                     crossAxisSpacing: 12,
  //                     childAspectRatio: 3.2, // wider chip layout
  //                     shrinkWrap: true,
  //                     physics: const AlwaysScrollableScrollPhysics(),
  //                     children: [
  //                       // All Types chip
  //                       ChoiceChip(
  //                         label: const Text('All Types'),
  //                         selected: _selectedSubType == null,
  //                         onSelected: (selected) {
  //                           _updateBreadcrumbPath(
  //                             category: _selectedCategory,
  //                             subType: null,
  //                           );
  //                           Navigator.pop(context);
  //                         },
  //                         selectedColor: const Color(0xFF4A306D),
  //                         labelStyle: TextStyle(
  //                           fontSize: 16,
  //                           color: _selectedSubType == null
  //                               ? Colors.white
  //                               : Colors.black87,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 16,
  //                           vertical: 10,
  //                         ),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(25),
  //                           side: BorderSide(
  //                             color: _selectedSubType == null
  //                                 ? const Color(0xFF4A306D)
  //                                 : Colors.grey.shade300,
  //                             width: 1.2,
  //                           ),
  //                         ),
  //                         avatar: _selectedSubType == null
  //                             ? const Icon(
  //                                 Icons.check,
  //                                 size: 20,
  //                                 color: Colors.white,
  //                               )
  //                             : null,
  //                       ),

  //                       // Other subtype chips
  //                       ...subTypes.map((subType) {
  //                         final selected = _selectedSubType == subType;
  //                         return ChoiceChip(
  //                           label: Text(
  //                             _getSubTypeDisplayName(subType),
  //                             style: TextStyle(
  //                               fontSize: 16,
  //                               color: selected ? Colors.white : Colors.black87,
  //                               fontWeight: FontWeight.w600,
  //                             ),
  //                           ),
  //                           selected: selected,
  //                           onSelected: (value) {
  //                             _updateBreadcrumbPath(
  //                               category: _selectedCategory,
  //                               subType: value ? subType : null,
  //                             );
  //                             Navigator.pop(context);
  //                           },
  //                           selectedColor: const Color(0xFF4A306D),
  //                           padding: const EdgeInsets.symmetric(
  //                             horizontal: 16,
  //                             vertical: 10,
  //                           ),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(25),
  //                             side: BorderSide(
  //                               color: selected
  //                                   ? const Color(0xFF4A306D)
  //                                   : Colors.grey.shade300,
  //                               width: 1.2,
  //                             ),
  //                           ),
  //                           avatar: selected
  //                               ? const Icon(
  //                                   Icons.check,
  //                                   size: 20,
  //                                   color: Colors.white,
  //                                 )
  //                               : null,
  //                         );
  //                       }),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
