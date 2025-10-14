import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/order_service.dart';
import '../../utils/snackbar_helper.dart';
import '../../constants/app_constants.dart';
import '../../widgets/suggestion_card.dart';

// --- MOCK ADD-ON DATA ---
// We define a simple model and a list of mock add-ons for demonstration
class AddOn {
  final String id;
  final String name;
  final double price;
  final IconData icon;

  const AddOn({required this.id, required this.name, required this.price, required this.icon});
}

const List<AddOn> _mockAddOns = [
  AddOn(id: 'a1', name: 'Extended 1 Year Warranty', price: 49.99, icon: Icons.security),
  AddOn(id: 'a2', name: 'Premium Installation Service', price: 99.00, icon: Icons.build),
  AddOn(id: 'a3', name: 'Product Cleaning Kit', price: 19.50, icon: Icons.clean_hands),
];

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final OrderService _orderService = OrderService();
  
  // State to track selected add-ons by their ID
  final Set<String> _selectedAddOnIds = {};

  // NEW: State to track selected payment option (kept for future expansion, currently unused)
  String? _selectedPaymentOptionId;

  // Helper method to toggle the selection of an add-on
  void _toggleAddOnSelection(String addOnId) {
    setState(() {
      if (_selectedAddOnIds.contains(addOnId)) {
        _selectedAddOnIds.remove(addOnId);
      } else {
        _selectedAddOnIds.add(addOnId);
      }
    });
  }
  
  // Widget to build the breadcrumbs navigation path
  Widget _buildBreadcrumbs() {
    final Product product = widget.product;
    // Define the path components: Home > Category > Sub-Type > Product Name
    final path = [
      {'name': 'Home', 'isLink': true},
      {'name': product.categoryDisplayName, 'isLink': true},
      {'name': product.subTypeDisplayName, 'isLink': true},
      {'name': product.name, 'isLink': false},
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: path.map((item) {
            final int index = path.indexOf(item);
            final bool isLast = index == path.length - 1;
            
            final Widget textWidget = Text(
              item['name'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: isLast ? Colors.deepPurple.shade900 : Colors.grey.shade600,
                fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
              ),
            );

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                item['isLink'] as bool
                  ? InkWell(
                      onTap: () {
                        // Handle navigation (e.g., pop to category screen)
                        SnackbarHelper.showSnackBar(
                          context,
                          message: 'Navigating to ${item['name']}...',
                          backgroundColor: Colors.deepPurple.shade300,
                        );
                      },
                      child: textWidget,
                    )
                  : textWidget,
                
                if (!isLast)
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.grey,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Widget for the Add-ons Stepper/Selector
  Widget _buildAddOnsSelector() {
    if (_mockAddOns.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Add-ons & Services',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // List of Add-ons (Stepper-like selection)
        ..._mockAddOns.map((addOn) {
          final isSelected = _selectedAddOnIds.contains(addOn.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () => _toggleAddOnSelection(addOn.id),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : addOn.icon,
                      color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addOn.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.deepPurple.shade900 : Colors.black87,
                            ),
                          ),
                          Text(
                            '${AppConstants.currencySymbol}${addOn.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
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
        }).toList(),
        
        const SizedBox(height: 20),
        const Divider(),
      ],
    );
  }

  // Use null-aware operator '?? const []'
  Widget _buildSuggestionsSection(BuildContext context) {
    final List<Product?> alternatives = (widget.product.alternativeProductIds ?? const [])
        .map((id) => AppConstants.getProductById(id))
        .where((p) => p != null)
        .toList();

    final List<Product?> upgrades = (widget.product.upgradeProductIds ?? const [])
        .map((id) => AppConstants.getProductById(id))
        .where((p) => p != null)
        .toList();

    // Combine into a single list of non-null Products
    final List<Product> allSuggestions = [...alternatives, ...upgrades].whereType<Product>().toList();
    
    if (allSuggestions.isEmpty) {
      return const SizedBox.shrink(); // Hide the section if no suggestions exist
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Functional Upgrades & Alternatives',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 200, // Fixed height for the horizontal list
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allSuggestions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final suggestedProduct = allSuggestions[index];
                
                // Determine the suggestion type label
                String suggestionType;
                if ((widget.product.alternativeProductIds ?? const []).contains(suggestedProduct.id)) {
                  suggestionType = 'Alternative';
                } else {
                  suggestionType = 'Upgrade';
                }

                return SuggestionCard(
                  product: suggestedProduct,
                  suggestionType: suggestionType,
                  onTap: () {
                    // Navigate to the suggested product's detail screen
                    // Replacing the current screen with the new one
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: suggestedProduct),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for the specifications row
  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Extracted widget for the image display
  Widget _buildProductImage(Product product, {required double height}) {
    return Hero(
      tag: 'product_${product.id}',
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: product.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12), // Added border radius for visual appeal
          image: DecorationImage(
            image: NetworkImage(product.imageUrl), 
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
  
  // Extracted widget for the right-hand details column content
  Widget _buildProductDetailsColumn() {
    final Product product = widget.product;
    
    // Mock RRP for demonstration (assuming no originalPrice property on Product)
    final double mockRrp = product.price * 1.30; // Assuming a 30% discount
    final double discountedPrice = product.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBreadcrumbs(),
        
        // Category & SubType Badges
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: product.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    product.categoryIcon,
                    size: 16,
                    color: product.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.categoryDisplayName,
                    style: TextStyle(
                      color: product.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    product.subTypeIcon,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.subTypeDisplayName,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Product Name
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
        ),
        
        const SizedBox(height: 16),
        
        // --- UPDATED PRICE SECTION (RRP & Discounted Price) ---
        // 1. RRP (Strikethrough)
        if (mockRrp > discountedPrice) // Only show RRP if it's actually higher
          Text(
            'RRP: ${AppConstants.currencySymbol}${mockRrp.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color.fromARGB(255, 180, 6, 6),
              fontWeight: FontWeight.normal,
              //decoration: TextDecoration.lineThrough, // Strikethrough
            ),
          ),

        // 2. Discounted Price and Tag
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${AppConstants.currencySymbol}${discountedPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color.fromARGB(255, 19, 201, 110), // Noticable color for discounted price
                  fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            if (mockRrp > discountedPrice)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 19, 201, 110),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'DISCOUNTED PRICE', // Discounted Tag
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        // --- END UPDATED PRICE SECTION ---
        
        const SizedBox(height: 16),
        
        // --- UPDATED STOCK STATUS (Now looks like a tag) ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: product.isInStock ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: product.isInStock ? Colors.green.shade300 : Colors.red.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                product.isInStock ? Icons.local_shipping : Icons.error_outline,
                color: product.isInStock ? Colors.green.shade700 : Colors.red.shade700,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                product.isInStock
                    ? 'IN STOCK: ${product.stockQuantity} units available.'
                    : 'CURRENTLY OUT OF STOCK.',
                style: TextStyle(
                  color: product.isInStock ? Colors.green.shade900 : Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        // --- END UPDATED STOCK STATUS ---
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final Product product = widget.product; 
    const double desktopBreakpoint = 800.0;

    // Calculate the total price including selected add-ons for the button label and snackbar
    final double addOnsTotal = _mockAddOns
        .where((a) => _selectedAddOnIds.contains(a.id))
        .fold(0.0, (sum, item) => sum + item.price);
    final double grandTotal = product.price + addOnsTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive main product area (Image + Details)
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > desktopBreakpoint;

                if (isDesktop) {
                  // Desktop/Wide View: Side-by-side layout
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Image
                        Expanded(
                          flex: 1,
                          child: _buildProductImage(product, height: 500),
                        ),
                        
                        const SizedBox(width: 48),

                        // Right Column: Details
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0), 
                            child: _buildProductDetailsColumn(),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Mobile/Narrow View: Stacked layout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image (Full width, fixed height)
                      _buildProductImage(product, height: 400),
                      
                      // Details (Padded)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildProductDetailsColumn(),
                      ),
                    ],
                  );
                }
              },
            ),

            // Full-width sections below the hero area 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // 1. Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                             fontWeight: FontWeight.bold,
                                           ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 2. Specifications
                  if (product.weight != null || product.maxUserWeight != null || product.colorName.isNotEmpty) ...[
                    Text(
                      'Specifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                               fontWeight: FontWeight.bold,
                                             ),
                    ),
                    const SizedBox(height: 12),
                    if (product.weight != null)
                      _buildSpecRow('Weight', '${product.weight} kg'),
                    if (product.maxUserWeight != null)
                      _buildSpecRow('Max User Weight', '${product.maxUserWeight} kg'),
                    _buildSpecRow('Color', product.colorName),
                    const SizedBox(height: 24),
                  ],
                  
                  // 3. Features
                  Text(
                    'Features',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                               fontWeight: FontWeight.bold,
                                             ),
                    ),
                  const SizedBox(height: 12),
                  // List of features using the spread operator
                  ...product.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  )),
                  
                  const Divider(height: 32), // Added separator for visual clarity between core info and add-ons

                  // 4. ADD-ONS SECTION
                  _buildAddOnsSelector(),
                  
                  // 5. Suggestions Section
                  _buildSuggestionsSection(context),

                  const SizedBox(height: 40), // Extra space at the bottom to accommodate sticky footer
                ],
              ),
            ),
          ],
        ),
      ),
      // --- bottomNavigationBar with Total Price and Add to Cart Button ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5), // Shadow above the bar
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Essential to keep the column size tight
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Price Summary
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Grand Total (incl. add-ons)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const Text(
                            'Your Price Today',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '${AppConstants.currencySymbol}${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.w900, 
                          color: Colors.deepPurple
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(), 
                const SizedBox(height: 16),
                
                // 2. Add to Cart Button (The main action)
                ElevatedButton(
                  onPressed: product.isInStock
                      ? () {
                          // Find the selected AddOn objects
                          final selectedAddOns = _mockAddOns
                              .where((addOn) => _selectedAddOnIds.contains(addOn.id))
                              .toList();
                              
                          // Add product to cart
                          _orderService.addToCart(product); 
                          
                          // Build confirmation message
                          final String addOnMessage = selectedAddOns.isNotEmpty 
                              ? ' including ${selectedAddOns.length} add-on(s)' 
                              : '';
                              
                          // Show confirmation snackbar
                          SnackbarHelper.showSnackBar(
                            context,
                            message: 'Item and total of ${AppConstants.currencySymbol}${grandTotal.toStringAsFixed(2)}$addOnMessage added to cart!',
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.deepPurple,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  // Simplified button text since total price is shown above
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart),
                      SizedBox(width: 12),
                      Text('Add to Cart'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
