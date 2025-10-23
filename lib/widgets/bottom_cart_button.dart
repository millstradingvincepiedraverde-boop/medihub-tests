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
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1000;
    final bool isDesktop = screenWidth >= 1000;

    // Scale settings for all screen sizes
    final double iconSize = isDesktop ? 38 : (isTablet ? 34 : 30);
    final double fontSizeSmall = isDesktop ? 16 : (isTablet ? 15 : 13);
    final double fontSizeLarge = isDesktop ? 24 : (isTablet ? 22 : 18);
    final double paddingVertical = isDesktop ? 30 : (isTablet ? 26 : 20);
    final double paddingHorizontal = isDesktop ? 40 : (isTablet ? 28 : 20);
    final double buttonFontSize = isDesktop ? 18 : (isTablet ? 16 : 14);

    return AnimatedBuilder(
      animation: _orderService,
      builder: (context, _) {
        final int itemCount = _orderService.cartItemCount;
        final double total = _orderService.cartTotal;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF4A306D),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🛒 Cart Info Section
                Expanded(
                  flex: isMobile ? 0 : 1,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isMobile ? 12 : 0),
                    child: Row(
                      mainAxisAlignment: isMobile
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: iconSize,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                                style: TextStyle(
                                  fontSize: fontSizeSmall,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(
                                    255,
                                    245,
                                    245,
                                    245,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (!isMobile) const SizedBox(width: 16),

                // 🧾 View Orders Button
                Expanded(
                  flex: isMobile ? 0 : 2,
                  child: SizedBox(
                    width: double.infinity,
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
                        foregroundColor: const Color(0xFF4A306D),
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 14 : 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Orders and Pay',
                            style: TextStyle(
                              fontSize: buttonFontSize,
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: buttonFontSize - 3,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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
