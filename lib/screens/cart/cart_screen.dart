// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:medihub_tests/controllers/product_controller.dart';
import 'package:medihub_tests/models/product.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // Lottie import
// import 'package:lottie/lottie.dart'; // Uncomment when you add Lottie animations
import '../../services/order_service.dart';
import '../checkout/customer_checkout_screen.dart';
import '../../widgets/suggestion_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();

  // Slide controller for the whole cart area (ease-in-from-bottom)
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  // Optional Lottie controller if you want programmatic control (looping etc.)
  // late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.12), // slightly below the screen
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start the slide animation shortly after build for a smooth effect.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _slideController.forward();
      }
    });

    // If you want to control the Lottie animation programmatically:
    // _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _slideController.dispose();
    // _lottieController.dispose();
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

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              children: [
                // === HEADER WITH LOTTIE ICON ANIM ===
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Shopping Cart Icon - Replace with Lottie when available
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
                                child: const Icon(
                                  Icons.shopping_cart,
                                  size: 32,
                                  color: Color(0xFF4A306D),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Shopping Cart',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black87,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // === COLUMN HEADERS ===
                if (cartItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        SizedBox(
                          width: isMobile ? 80 : 100,
                          child: const Center(
                            child: Text(
                              'Qty',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? 90 : 110,
                          child: const Center(
                            child: Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? 90 : 110,
                          child: const Center(
                            child: Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 50),
                      ],
                    ),
                  ),

                // === MAIN CART (SLIDE TRANSITION FROM BOTTOM) ===
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: cartItems.isEmpty
                        ? Container(
                            color: Colors.white,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Lottie animation for empty cart (local asset if available)
                                  // If you haven't added the local asset yet, you can use Lottie.network for quick testing.
                                  SizedBox(
                                    width: 180,
                                    height: 180,
                                    child: Builder(
                                      builder: (context) {
                                        // Try to load local asset first; if missing, fallback to network animation.
                                        // NOTE: If you always have the local asset present, you can directly use Lottie.asset('assets/lottie/empty_cart.json')
                                        try {
                                          return Lottie.asset(
                                            'assets/lottie/empty_cart.json',
                                            width: 180,
                                            height: 180,
                                            repeat: false,
                                            // controller: _lottieController, // optional
                                          );
                                        } catch (e) {
                                          // Fallback network file (useful for initial testing)
                                          return Lottie.network(
                                            'https://assets7.lottiefiles.com/private_files/lf30_jmgekfqg.json',
                                            width: 180,
                                            height: 180,
                                            repeat: false,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Your cart is empty',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Add items to get started',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              itemCount: cartItems.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Color(0xFFE5E5E5),
                                  ),
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                // Animate each item with staggered delay
                                return TweenAnimationBuilder(
                                  key: ValueKey(item.product.id),
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, double value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(30 * (1 - value), 0),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _buildCartItem(item, isMobile),
                                );
                              },
                            ),
                          ),
                  ),
                ),

                // === SUMMARY AND BUTTONS ===
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Summary
                      if (cartItems.isNotEmpty)
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${cartItems.length} Items:',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
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
                        ),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: cartItems.isNotEmpty
                                  ? () => setState(
                                      () => _orderService.clearCart(),
                                    )
                                  : null,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                side: BorderSide(
                                  color: cartItems.isNotEmpty
                                      ? Colors.black87
                                      : Colors.grey.shade300,
                                  width: 1,
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
                                  ? () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          opaque: false,
                                          barrierDismissible: true,
                                          pageBuilder: (context, _, __) =>
                                              const CustomerInfoScreen(),
                                          transitionsBuilder:
                                              (context, animation, _, child) =>
                                                  child,
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A306D),
                                disabledBackgroundColor: Colors.grey.shade300,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
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
                      ),
                    ],
                  ),
                ),

                // === SUGGESTIONS ===
                _buildSuggestions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItem(cartItem, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Row(
        children: [
          // Product Image
          Container(
            width: isMobile ? 80 : 120,
            height: isMobile ? 80 : 120,
            decoration: BoxDecoration(
              color:
                  cartItem.product.color?.withOpacity(0.1) ??
                  Colors.grey.shade100,
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
                    size: 40,
                    color: cartItem.product.color ?? Colors.grey,
                  ),
          ),
          const SizedBox(width: 16),

          // Product Name
          Expanded(
            child: Text(
              cartItem.product.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Quantity Controls
          SizedBox(
            width: isMobile ? 80 : 100,
            child: _quantityControl(cartItem),
          ),

          // Price
          SizedBox(
            width: isMobile ? 90 : 110,
            child: Center(
              child: Text(
                '\$${cartItem.product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Total
          SizedBox(
            width: isMobile ? 90 : 110,
            child: Center(
              child: Text(
                '\$${cartItem.totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Delete Button
          SizedBox(
            width: 50,
            child: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.black54,
                size: 22,
              ),
              onPressed: () => setState(
                () => _orderService.removeFromCart(cartItem.product.id),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityControl(cartItem) {
    return Row(
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '${cartItem.quantity}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}
