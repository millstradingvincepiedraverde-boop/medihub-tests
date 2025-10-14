import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../widgets/cart_item_widget.dart';
import '../../constants/app_constants.dart';
import '../checkout/customer_info_screen.dart';
// 💡 Import the SuggestionCard widget
import '../../widgets/suggestion_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final OrderService _orderService = OrderService();

  // Helper method to simulate navigation when a suggestion is tapped
  void _navigateToProduct(String productId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to product ${AppConstants.getProductById(productId)?.name ?? productId}'),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // NEW METHOD: Aggregates and displays product suggestions
  // ----------------------------------------------------------------------
  Widget _buildSuggestions() {
    final cartItems = _orderService.cartItems;

    if (cartItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1. Aggregate all unique suggestion IDs from items in the cart
    final Set<String> allSuggestionIds = {};
    final Map<String, String> suggestionIdToType = {}; // Maps ID to 'Alternative' or 'Upgrade'

    for (final item in cartItems) {
      // Collect Alternatives
      for (final altId in item.product.alternativeProductIds) {
        // Only suggest if it's not already in the cart
        if (!_orderService.isProductInCart(altId)) {
          allSuggestionIds.add(altId);
          suggestionIdToType[altId] = 'Alternative';
        }
      }

      // Collect Upgrades/Accessories
      for (final upId in item.product.upgradeProductIds) {
        // Only suggest if it's not already in the cart
        if (!_orderService.isProductInCart(upId)) {
          allSuggestionIds.add(upId);
          // If a product is listed as both, we prioritize calling it an 'Upgrade'
          suggestionIdToType[upId] = 'Upgrade';
        }
      }
    }

    // 2. Retrieve Product objects and build widgets
    final List<Widget> suggestionCards = [];
    for (final id in allSuggestionIds) {
      final product = AppConstants.getProductById(id);
      if (product != null) {
        suggestionCards.add(
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SuggestionCard(
              product: product,
              suggestionType: suggestionIdToType[id]!,
              onTap: () => _navigateToProduct(id),
            ),
          ),
        );
      }
    }

    if (suggestionCards.isEmpty) {
      return const SizedBox.shrink();
    }

    // 3. Display the suggestions in a horizontal list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Suggested Add-ons & Alternatives',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180, // Fixed height for horizontal list
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            children: suggestionCards,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------------
  // BUILD METHOD
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final cartItems = _orderService.cartItems;
    final subtotal = _orderService.cartTotal;
    final tax = subtotal * 0.12; // 12% tax
    final total = subtotal + tax;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                      'Are you sure you want to remove all items from your cart?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _orderService.clearCart();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear'),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    // ListView.builder converted to a regular ListView to easily insert the suggestion widget
                    children: [
                      // List of Cart Items
                      ...cartItems.map((item) {
                        return CartItemWidget(
                          orderItem: item,
                          onQuantityChanged: (quantity) {
                            setState(() {
                              _orderService.updateQuantity(
                                item.product.id,
                                quantity,
                              );
                            });
                          },
                          onRemove: () {
                            setState(() {
                              _orderService.removeFromCart(
                                item.product.id,
                              );
                            });
                          },
                        );
                      }).toList(),
                      
                      // 💡 Display Suggestions after cart items
                      _buildSuggestions(),
                    ],
                  ),
                ),
                _buildCartSummary(subtotal, tax, total),
              ],
            ),
    );
  }

  // ----------------------------------------------------------------------
  // EXISTING METHODS
  // ----------------------------------------------------------------------

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(double subtotal, double tax, double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', subtotal),
          const SizedBox(height: 8),
          _buildSummaryRow('Tax (12%)', tax),
          const Divider(height: 24),
          _buildSummaryRow('Total', total, isTotal: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerInfoScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '${AppConstants.currencySymbol}${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.green : null,
          ),
        ),
      ],
    );
  }
}