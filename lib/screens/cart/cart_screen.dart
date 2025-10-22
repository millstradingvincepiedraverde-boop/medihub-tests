import 'package:flutter/material.dart';
import 'package:medihub_tests/controllers/product_controller.dart';
import 'package:medihub_tests/models/product.dart';
import 'package:provider/provider.dart';
import '../../services/order_service.dart';
import '../../constants/app_constants.dart';
import '../checkout/customer_checkout_screen.dart';
import '../../widgets/suggestion_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final OrderService _orderService = OrderService();

  void _navigateToProduct(String productId) {
    final productController = context.read<ProductController>();
    final product = productController.products.firstWhere(
      (p) => p.id == productId,
      orElse: () => Product.empty(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          product.id.isNotEmpty
              ? 'Navigating to product ${product.name}'
              : 'Product $productId not found',
        ),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  Widget _buildSuggestions() {
    final cartItems = _orderService.cartItems;
    if (cartItems.isEmpty) return const SizedBox.shrink();

    final productController = context.watch<ProductController>();

    final Set<String> allSuggestionIds = {};
    final Map<String, String> suggestionIdToType = {};

    for (final item in cartItems) {
      // Collect alternative product IDs
      for (final altId in item.product.alternativeProductIds) {
        if (!_orderService.isProductInCart(altId)) {
          allSuggestionIds.add(altId);
          suggestionIdToType[altId] = 'Alternative';
        }
      }

      // Collect upgrade product IDs
      for (final upId in item.product.upgradeProductIds) {
        if (!_orderService.isProductInCart(upId)) {
          allSuggestionIds.add(upId);
          suggestionIdToType[upId] = 'Upgrade';
        }
      }
    }

    final List<Widget> suggestionCards = [];
    for (final id in allSuggestionIds) {
      final product = productController.products.firstWhere(
        (p) => p.id == id,
        orElse: () => Product.empty(),
      );

      if (product.id.isNotEmpty) {
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

    return suggestionCards.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'You might also like',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: suggestionCards,
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _orderService.cartItems;
    final total = _orderService.cartTotal;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            // === HEADER ===
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shopping Cart',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // === COLUMN HEADERS ===
            if (cartItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(120, 0, 24, 12),
                child: Row(
                  children: const [
                    Spacer(),
                    SizedBox(
                      width: 120,
                      child: Center(
                        child: Text(
                          'Qty',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Center(
                        child: Text(
                          'Price',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Center(
                        child: Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 50),
                  ],
                ),
              ),

            // === MAIN CART SECTION ===
            Expanded(
              child: cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              // Product Image
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: item.product.color?.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: item.product.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.product.imageUrl,
                                        fit: BoxFit.contain,
                                      )
                                    : Icon(
                                        item.product.categoryIcon,
                                        size: 40,
                                        color: item.product.color,
                                      ),
                              ),
                              const SizedBox(width: 16),

                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Color: ${item.product.colorName}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Controls
                              SizedBox(
                                width: 120,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 18,
                                        onPressed: () {
                                          if (item.quantity > 1) {
                                            setState(() {
                                              _orderService.updateQuantity(
                                                item.product.id,
                                                item.quantity - 1,
                                              );
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.remove),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 18,
                                        onPressed: () {
                                          setState(() {
                                            _orderService.updateQuantity(
                                              item.product.id,
                                              item.quantity + 1,
                                            );
                                          });
                                        },
                                        icon: const Icon(Icons.add),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Price
                              SizedBox(
                                width: 80,
                                child: Center(
                                  child: Text(
                                    '\$${item.product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),

                              // Total
                              SizedBox(
                                width: 80,
                                child: Center(
                                  child: Text(
                                    '\$${item.totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),

                              // Delete Button
                              SizedBox(
                                width: 50,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _orderService.removeFromCart(
                                        item.product.id,
                                      );
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.black54,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // === SUMMARY ROW ===
            if (cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                color: const Color(0xFFF5F5F5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${cartItems.length} Items:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

            // === FIXED BUTTON BAR ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: cartItems.isNotEmpty
                        ? () {
                            setState(() => _orderService.clearCart());
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      side: const BorderSide(
                        color: Color(0xFF4A306D),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Clear All Items',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF4A306D),
                      ),
                    ),
                  ),

                  // In your cart_screen.dart, replace the checkout button's onPressed with this:
                  ElevatedButton(
                    onPressed: cartItems.isNotEmpty
                        ? () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false, // Makes background transparent
                                barrierDismissible: true,
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                      return const CustomerInfoScreen();
                                    },
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return child; // No additional transition needed, the CustomerInfoScreen has its own
                                    },
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A306D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue to Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // === "People also bought" SECTION ===
            _buildSuggestions(),
          ],
        ),
      ),
    );
  }
}
