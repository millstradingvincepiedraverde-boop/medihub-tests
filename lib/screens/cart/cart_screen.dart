import 'package:flutter/material.dart';
import 'package:medihub_tests/controllers/product_controller.dart';
import 'package:medihub_tests/models/product.dart';
import 'package:provider/provider.dart';
import '../../services/order_service.dart';
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
      for (final altId in item.product.alternativeProductIds) {
        if (!_orderService.isProductInCart(altId)) {
          allSuggestionIds.add(altId);
          suggestionIdToType[altId] = 'Alternative';
        }
      }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final bool isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        final bool isDesktop = constraints.maxWidth >= 1024;

        final double horizontalPadding = isMobile ? 16 : 24;
        final double imageSize = isMobile ? 60 : 80;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // === HEADER ===
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shopping Cart',
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF191919),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // === COLUMN HEADERS (desktop/tablet only) ===
                if (!isMobile && cartItems.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(120, 0, horizontalPadding, 12),
                    child: Row(
                      children: const [
                        Spacer(),
                        SizedBox(width: 120, child: Center(child: Text('Qty'))),
                        SizedBox(
                          width: 80,
                          child: Center(child: Text('Price')),
                        ),
                        SizedBox(
                          width: 80,
                          child: Center(child: Text('Total')),
                        ),
                        SizedBox(width: 50),
                      ],
                    ),
                  ),

                // === MAIN CART ===
                Expanded(
                  child: cartItems.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Your cart is empty',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 8,
                          ),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: isMobile
                                  ? _buildMobileCartItem(item, imageSize)
                                  : _buildDesktopCartItem(item, imageSize),
                            );
                          },
                        ),
                ),

                // === SUMMARY ROW ===
                if (cartItems.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16,
                    ),
                    color: const Color(0xFFF5F5F5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${cartItems.length} Items:',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                // === BUTTONS ===
                _buildButtonBar(isMobile, cartItems),

                // === SUGGESTIONS ===
                _buildSuggestions(),
              ],
            ),
          ),
        );
      },
    );
  }

  // MOBILE CART ITEM
  Widget _buildMobileCartItem(cartItem, double imageSize) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                color: cartItem.product.color?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: cartItem.product.imageUrl.isNotEmpty
                  ? Image.network(
                      cartItem.product.imageUrl,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      cartItem.product.categoryIcon,
                      size: 30,
                      color: cartItem.product.color,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                cartItem.product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(
                  () => _orderService.removeFromCart(cartItem.product.id),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _quantityControl(cartItem),
            Text(
              '\$${cartItem.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  // DESKTOP/TABLET CART ITEM
  Widget _buildDesktopCartItem(cartItem, double imageSize) {
    return Row(
      children: [
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: cartItem.product.color?.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: cartItem.product.imageUrl.isNotEmpty
              ? Image.network(cartItem.product.imageUrl, fit: BoxFit.contain)
              : Icon(
                  cartItem.product.categoryIcon,
                  size: 40,
                  color: cartItem.product.color,
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            cartItem.product.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(width: 120, child: Center(child: _quantityControl(cartItem))),
        SizedBox(
          width: 80,
          child: Center(
            child: Text('\$${cartItem.product.price.toStringAsFixed(0)}'),
          ),
        ),
        SizedBox(
          width: 80,
          child: Center(
            child: Text('\$${cartItem.totalPrice.toStringAsFixed(0)}'),
          ),
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
            onPressed: () => setState(
              () => _orderService.removeFromCart(cartItem.product.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quantityControl(cartItem) {
    return Row(
      children: [
        _qtyButton(Icons.remove, () {
          if (cartItem.quantity > 1) {
            setState(
              () => _orderService.updateQuantity(
                cartItem.product.id,
                cartItem.quantity - 1,
              ),
            );
          }
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${cartItem.quantity}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        _qtyButton(Icons.add, () {
          setState(
            () => _orderService.updateQuantity(
              cartItem.product.id,
              cartItem.quantity + 1,
            ),
          );
        }),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildButtonBar(bool isMobile, List cartItems) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 20,
      ),
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
      child: isMobile
          ? Column(
              children: [
                _buildClearButton(cartItems, fullWidth: true),
                const SizedBox(height: 12),
                _buildCheckoutButton(cartItems, fullWidth: true),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildClearButton(cartItems),
                _buildCheckoutButton(cartItems),
              ],
            ),
    );
  }

  Widget _buildClearButton(List cartItems, {bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: cartItems.isNotEmpty
            ? () => setState(() => _orderService.clearCart())
            : null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          side: const BorderSide(color: Color(0xFF4A306D), width: 2),
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
    );
  }

  Widget _buildCheckoutButton(List cartItems, {bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: cartItems.isNotEmpty
            ? () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    barrierDismissible: false,
                    pageBuilder: (context, _, __) => const CustomerInfoScreen(),
                    transitionsBuilder: (context, animation, _, child) => child,
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A306D),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
    );
  }
}
