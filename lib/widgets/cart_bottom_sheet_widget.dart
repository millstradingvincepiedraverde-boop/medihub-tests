// lib/screens/cart/cart_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:medihub_tests/screens/checkout/customer_checkout_screen.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import 'package:medihub_tests/controllers/product_controller.dart';
import 'package:medihub_tests/models/product.dart';
import '../services/order_service.dart';

import 'suggestion_card.dart';

class CartBottomSheet extends StatefulWidget {
  const CartBottomSheet({super.key});

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_cart, size: 28, color: Color(0xFF4A306D)),
              SizedBox(width: 12),
              Text(
                'Shopping Cart',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ],
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

    if (suggestionCards.isEmpty) return const SizedBox.shrink();

    return Column(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _orderService.cartItems;
    final total = _orderService.cartTotal;

    return FractionallySizedBox(
      heightFactor: 0.9,
      widthFactor: 1.0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              _buildHeader(),

              // === Scrollable Body ===
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 140),
                    child: Column(
                      children: [
                        if (cartItems.isEmpty)
                          _buildEmptyCart()
                        else
                          Column(
                            children: [
                              _buildCartHeader(),
                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                itemCount: cartItems.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: Color(0xFFE5E5E5),
                                ),
                                itemBuilder: (context, index) {
                                  final item = cartItems[index];
                                  return TweenAnimationBuilder(
                                    key: ValueKey(item.product.id),
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 400),
                                    builder: (context, value, child) => Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(30 * (1 - value), 0),
                                        child: child,
                                      ),
                                    ),
                                    child: _buildCartItem(item),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildSuggestions(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // === Fixed Bottom Summary & Buttons ===
              if (cartItems.isNotEmpty)
                Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSummary(cartItems.length, total),
                      const SizedBox(height: 8),
                      _buildButtons(cartItems),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: Lottie.asset(
              'assets/animations/empty_cart.json',
              repeat: false,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black38,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.white,
      child: const Row(
        children: [
          Expanded(child: SizedBox()),
          SizedBox(
            width: 90,
            child: Center(
              child: Text(
                'Qty',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Center(
              child: Text(
                'Price',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Center(
              child: Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildCartItem(cartItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color:
                  cartItem.product.color?.withOpacity(0.1) ?? Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: cartItem.product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      cartItem.product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    cartItem.product.categoryIcon,
                    size: 36,
                    color: cartItem.product.color ?? Colors.grey,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              cartItem.product.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                decoration: TextDecoration.none,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 80, child: _quantityControl(cartItem)),
          SizedBox(
            width: 100,
            child: Center(
              child: Text(
                '\$${cartItem.product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Center(
              child: Text(
                '\$${cartItem.totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  decoration: TextDecoration.none,
                ),
              ),
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
      ),
    );
  }

  Widget _quantityControl(cartItem) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              '${cartItem.quantity}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
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
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 16,
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSummary(int itemCount, double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$itemCount Items:',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(cartItems) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: cartItems.isNotEmpty
                ? () => setState(() => _orderService.clearCart())
                : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(
                color: cartItems.isNotEmpty
                    ? Colors.black87
                    : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Clear All Items',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: cartItems.isNotEmpty
                    ? Colors.black87
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: cartItems.isNotEmpty
                ? () => showCustomerInfoModal(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A306D),
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Complete Order',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
