import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'cart_bottom_sheet_widget.dart';

class BottomCartButton extends StatefulWidget {
  final VoidCallback? onCartChanged;

  const BottomCartButton({super.key, this.onCartChanged});

  @override
  State<BottomCartButton> createState() => _BottomCartButtonState();
}

class _BottomCartButtonState extends State<BottomCartButton> {
  final OrderService _orderService = OrderService();

  void _openCart(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cart",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.85,
              widthFactor: 1.0,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  // Prevent drag gestures from bubbling to background
                  onVerticalDragStart: (_) {},
                  child: const CartBottomSheet(),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    final double iconSize = isDesktop ? 50 : (isTablet ? 44 : 34);
    final double fontSizeSmall = isDesktop ? 20 : (isTablet ? 18 : 14);
    final double fontSizeLarge = isDesktop ? 32 : (isTablet ? 26 : 20);
    final double buttonFontSize = isDesktop ? 22 : (isTablet ? 20 : 16);

    final double paddingVertical = isDesktop ? 60 : (isTablet ? 40 : 18);
    final double paddingHorizontal = isDesktop ? 64 : (isTablet ? 40 : 20);

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
                      // 🛒 Cart Info
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Icon(Icons.shopping_cart,
                              color: Colors.white, size: iconSize),
                          Text(
                            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                            style: TextStyle(
                              fontSize: fontSizeSmall,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const Text('•',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold)),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              itemCount > 0 ? () => _openCart(context) : null,
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
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'View Orders and Pay',
                                    style: TextStyle(
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (itemCount > 0) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
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
                    children: [
                      // 🛍️ Cart Info Section
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.shopping_cart,
                                color: Colors.white, size: iconSize),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                '$itemCount ${itemCount == 1 ? 'item' : 'items'}  •  \$${total.toStringAsFixed(2)}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: fontSizeLarge,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // 💳 View Orders Button
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                itemCount > 0 ? () => _openCart(context) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4A306D),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 26.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'View Orders and Pay',
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                if (itemCount > 0) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A306D),
                                      borderRadius: BorderRadius.circular(14),
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
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
