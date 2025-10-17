import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../screens/cart/cart_screen.dart';

class BottomCartButton extends StatefulWidget {
  final VoidCallback? onCartChanged;

  const BottomCartButton({super.key, this.onCartChanged});

  @override
  State<BottomCartButton> createState() => _BottomCartButtonState();
}

class _BottomCartButtonState extends State<BottomCartButton> {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _orderService,
      builder: (context, _) {
        final int itemCount = _orderService.cartItemCount;
        final double total = _orderService.cartTotal;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
          decoration: BoxDecoration(
            color: const Color(0xFF4A306D),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // 🛒 Cart Info
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '•',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 245, 245, 245),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // 🧾 View Orders & Pay
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: itemCount > 0
                        ? () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                opaque: false,
                                transitionDuration: const Duration(
                                  milliseconds: 350,
                                ),
                                pageBuilder: (context, animation, _) {
                                  return GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      color: Colors.black.withOpacity(0.4),
                                      alignment: Alignment.bottomCenter,
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: const FractionallySizedBox(
                                          heightFactor: 0.85,
                                          widthFactor: 1.0,
                                          child: CartScreen(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                transitionsBuilder:
                                    (context, animation, _, child) {
                                      const begin = Offset(0.0, 1.0);
                                      const end = Offset.zero;
                                      final tween =
                                          Tween(begin: begin, end: end).chain(
                                            CurveTween(
                                              curve: Curves.easeOutCubic,
                                            ),
                                          );

                                      return FadeTransition(
                                        opacity: CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                        ),
                                        child: SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        ),
                                      );
                                    },
                              ),
                            ).then((_) {
                              if (mounted) setState(() {});
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromARGB(255, 77, 1, 128),
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'View Orders and Pay',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (itemCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A306D),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$itemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
