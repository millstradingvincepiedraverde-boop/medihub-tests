import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_constants.dart';
import '../../models/product.dart';
import '../../services/order_service.dart';
import '../../widgets/product_card.dart';
import '../../utils/snackbar_helper.dart';
import '../cart/cart_screen.dart';
import 'product_detail_screen.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final OrderService _orderService = OrderService();

  static const double _kTabletBreakpoint = 800.0;

  ProductCategory? _selectedCategory;
  dynamic _selectedSubType;

  String _searchQuery = '';

  late final TextEditingController _searchController;

  List<String> _breadcrumbPath = ['Home'];

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    var products = _selectedCategory == null
        ? AppConstants.productCatalog
        : AppConstants.getProductsByCategory(_selectedCategory!);

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

  String _getSubTypeDisplayName(dynamic subType) {
    if (subType == null) return 'All';

    final tempProduct = Product(
      id: '',
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

  List<dynamic> _getSubTypesForCategory(ProductCategory category) {
    switch (category) {
      case ProductCategory.wheelchairs:
        // Assuming WheelchairType is imported or globally available
        return WheelchairType.values;
      case ProductCategory.mobilityScooters:
        return MobilityScooterType.values;
      case ProductCategory.dailyLivingAids:
        return DailyLivingAidType.values;
      case ProductCategory.homeHealthCare:
        return HomeHealthCareType.values;
    }
  }

  // --- FIX: SAFE LOOKUP HELPER FUNCTION ---
  ProductCategory? _getCategoryFromDisplayName(String displayName) {
    for (var category in ProductCategory.values) {
      // Create a temporary product to check its display name
      final tempProduct = Product(
        id: '',
        name: '',
        description: '',
        category: category,
        subType: null,
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
          name: '',
          description: '',
          category: category,
          subType: null,
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
                      ? const Color.fromARGB(255, 77, 5, 87)
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
                style: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                _showSubcategoryFilter(context);
              },
            ),
        ],
      ),
    );
  }

  // NEW HERO BANNER WIDGET
  Widget _buildHeroBanner(double screenWidth) {
    // Determine height and padding responsively
    final bannerHeight = screenWidth * 0.35 > 250 ? 250.0 : screenWidth * 0.35;
    final padding = screenWidth > _kTabletBreakpoint ? 24.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      child: Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 71, 3, 88), // Medihub main color
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          // Use a subtle gradient for visual appeal
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 100, 50, 150).withOpacity(0.9),
              const Color.fromARGB(255, 71, 3, 88),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background graphic (subtle icon)
            Positioned(
              right: -50,
              bottom: -50,
              child: Icon(
                Icons.healing_outlined,
                size: bannerHeight * 1.1,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding * 1.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Featured Aid: The Ergonomic Walker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24, // Clear and large
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Experience enhanced mobility with our top-rated lightweight aluminum walker. Limited-time offer: 20% off all mobility aids!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Action: Navigate to the featured product or sale category (e.g., Mobility Scooters)
                      _updateBreadcrumbPath(
                        category: ProductCategory.mobilityScooters,
                        subType: null,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 71, 3, 88),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('Shop the Offer Now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Main Product Grid Area (now responsive)
  Widget _buildMainProductArea(double screenWidth) {
    // Determine crossAxisCount based on screen width
    int crossAxisCount;
    // ADJUSTED: Fewer columns for larger cards
    if (screenWidth >= 1200) {
      crossAxisCount = 3; // Reduced from 4
    } else if (screenWidth >= _kTabletBreakpoint) {
      crossAxisCount = 2; // Reduced from 3
    } else {
      crossAxisCount = 2; // Mobile view (kept 2)
    }

    return Column(
      children: [
        // BREADCRUMB
        _buildBreadcrumb(),

        // NEW: HERO BANNER
        if (_selectedCategory == null && _searchQuery.isEmpty)
          _buildHeroBanner(screenWidth),

        // Search and Filter Bar
        _buildSearchAndFilterBar(),

        // Header (Removed content, keeping container structure for potential future use)
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
              // Placeholder for potential sorting/view toggles
            ],
          ),
        ),

        // Grid
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
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // DYNAMIC CROSS AXIS COUNT
                    childAspectRatio: 0.8, // Slightly more height for cards
                    crossAxisSpacing: 20, // Increased spacing
                    mainAxisSpacing: 20, // Increased spacing
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      onAddToCart: () {
                        setState(() {
                          _orderService.addToCart(product);
                        });
                        SnackbarHelper.showSnackBar(
                          context,
                          message: '${product.name} added to cart',
                          behavior: SnackBarBehavior.floating,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= _kTabletBreakpoint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Products'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  ).then((_) => setState(() {}));
                },
              ),
              if (_orderService.cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_orderService.cartItemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLargeScreen
          ? Row(
              // Desktop/Tablet Layout: Sidebar beside content
              children: [
                _buildSidebar(),
                const VerticalDivider(width: 1),
                Expanded(child: _buildMainProductArea(screenWidth)),
              ],
            )
          : Column(
              // Mobile Layout: Category chips above content
              children: [
                _buildMobileCategoryChips(), // Replaces the sidebar
                Expanded(child: _buildMainProductArea(screenWidth)),
              ],
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
                name: '',
                description: '',
                category: category,
                subType: null,
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

  // NOTE: This code assumes you have defined the necessary enums (ProductCategory)
  // and classes (Product, AppConstants).

  // Import necessary packages (e.g., flutter/material.dart, flutter_svg.dart)

  // --- START: Helper Widget for Sidebar Tiles ---

  Widget _buildCategoryTile({
    required String label,
    required IconData icon,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
  }) {
    // Define the selection style: rounded background with a slight shadow.
    final Color primaryColor = const Color.fromARGB(255, 71, 3, 88);
    final Color backgroundColor = isSelected
        ? primaryColor
        : Colors.transparent;
    final Color labelColor = isSelected ? Colors.white : Colors.grey.shade800;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // Adding slight elevation and rounded corners for the selected state
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            // Add a subtle shadow when selected
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    icon, // Using the standard icon as a fallback/placeholder
                    color: isSelected ? Colors.white : primaryColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 2. LABEL TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: labelColor,
                      ),
                    ),
                    if (!isSelected) // Show count only if not selected
                      Text(
                        '$count items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    // Use the same primary color for the sidebar background color
    final Color primaryColor = const Color.fromARGB(255, 71, 3, 88);

    return Container(
      width: 280, // Fixed width for large screens
      // Change background to white or a lighter tone for better contrast with the tiles
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Area (Kept as is, using white background)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(children: [
             
            ],
          ),
          ),

          // Category List
          Expanded(
            child: ListView(
              // Removed vertical padding here since it's now in the tile
              padding: const EdgeInsets.symmetric(vertical: 0),
              children: [
                // All Products Tile
                _buildCategoryTile(
                  label: 'All Products',
                  icon: Icons.grid_view,
                  isSelected: _selectedCategory == null,
                  count: AppConstants.productCatalog.length,
                  onTap: () {
                    _updateBreadcrumbPath(category: null, subType: null);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ), // Increased horizontal padding
                  child: Divider(
                    height: 1,
                    color: Color.fromARGB(
                      255,
                      230,
                      230,
                      230,
                    ), // Lighter divider
                  ),
                ),
                // Dynamic Category Tiles
                ...ProductCategory.values.map((category) {
                  // ... (Your existing logic for calculating count and creating tempProduct)
                  final count = AppConstants.getProductsByCategory(
                    category,
                  ).length;
                  final tempProduct = Product(
                    id: '',
                    name: '',
                    description: '',
                    category: category,
                    subType: null,
                    price: 0,
                    imageUrl: '',
                    features: [],
                    stockQuantity: 0,
                    color: primaryColor,
                    colorName: '',
                  );
                  // ...

                  return _buildCategoryTile(
                    label: tempProduct.categoryDisplayName,
                    icon: tempProduct.categoryIcon,
                    isSelected:
                        _selectedCategory == category &&
                        _selectedSubType == null,
                    count: count,
                    onTap: () {
                      _updateBreadcrumbPath(category: category, subType: null);
                    },
                  );
                }),
              ],
            ),
          ),

          // Support Info (Refined for the bottom edge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                  color: primaryColor, // Consistent primary color
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Need Help?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                // Use a Column for tighter control over the link colors
                Column(
                  children: [
                    Text(
                      AppConstants.supportEmail,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      AppConstants.supportPhone,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
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

  void _showSubcategoryFilter(BuildContext context) {
    if (_selectedCategory == null) return;

    final subTypes = _getSubTypesForCategory(_selectedCategory!);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Type',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All Types'),
                  selected: _selectedSubType == null,
                  onSelected: (selected) {
                    // Update category with subType null
                    _updateBreadcrumbPath(
                      category: _selectedCategory,
                      subType: null,
                    );
                    Navigator.pop(context);
                  },
                ),
                ...subTypes.map((subType) {
                  return ChoiceChip(
                    label: Text(_getSubTypeDisplayName(subType)),
                    selected: _selectedSubType == subType,
                    onSelected: (selected) {
                      // Update category with selected subType
                      _updateBreadcrumbPath(
                        category: _selectedCategory,
                        subType: selected ? subType : null,
                      );
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
