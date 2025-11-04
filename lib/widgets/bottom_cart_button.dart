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

    // 🧱 Responsive breakpoints
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    // ✨ Responsive sizing
    final double iconSize = isDesktop ? 50 : (isTablet ? 46 : 36);
    final double fontSizeSmall = isDesktop ? 20 : (isTablet ? 18 : 14);
    final double fontSizeLarge = isDesktop ? 32 : (isTablet ? 28 : 20);
    final double paddingVertical = isDesktop
        ? 65
        : (isTablet ? 55 : 20); // 📱 tighter on mobile
    final double paddingHorizontal = isDesktop
        ? 64
        : (isTablet ? 40 : 20); // 📱 more compact on small screens
    final double buttonFontSize = isDesktop ? 22 : (isTablet ? 20 : 16);

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
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: isMobile
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                            style: TextStyle(
                              fontSize: fontSizeSmall,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: fontSizeLarge,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: itemCount > 0
                              ? () => _openCart(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4A306D),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A306D),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$itemCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: buttonFontSize - 2,
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
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🛒 Cart Info Section
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: iconSize,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '$itemCount ${itemCount == 1 ? 'item' : 'items'}  •  \$${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: fontSizeLarge,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // 🧾 View Orders Button
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: itemCount > 0
                                ? () => _openCart(context)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4A306D),
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
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
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A306D),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      '$itemCount',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: buttonFontSize - 1,
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

  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 350),
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
        transitionsBuilder: (context, animation, _, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: Curves.easeOutCubic));

          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
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
}
