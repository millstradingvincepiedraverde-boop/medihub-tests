import 'package:flutter/material.dart';
import 'package:animated_check/animated_check.dart';
import '../screens/cart/cart_screen.dart';

class ItemAddedDialog extends StatefulWidget {
  final String itemName;
  final String? imageUrl; // ✅ new
  final VoidCallback? onContinue;
  final VoidCallback? onViewCart;

  const ItemAddedDialog({
    super.key,
    required this.itemName,
    this.imageUrl,
    this.onContinue,
    this.onViewCart,
  });

  @override
  State<ItemAddedDialog> createState() => _ItemAddedDialogState();
}

class _ItemAddedDialogState extends State<ItemAddedDialog>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _textController;
  late AnimationController _imageController;
  late Animation<double> _checkAnimation;
  late Animation<double> _circleScale;
  late Animation<double> _textScale;
  late Animation<double> _imageScale;

  @override
  void initState() {
    super.initState();

    // 🖼️ Image "pop in" animation
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _imageScale = CurvedAnimation(
      parent: _imageController,
      curve: Curves.elasticOut,
    );

    // 🪩 Text "pop" animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _textScale = CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    );

    // ✅ Checkmark + circle animations
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOutExpo,
    );
    _circleScale = Tween<double>(begin: 0, end: 1.1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Sequence: image → text → check
    _imageController.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 200));
      _textController.forward();
      await Future.delayed(const Duration(milliseconds: 400));
      _checkController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _textController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _closeAll(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).maybePop();
  }

  void _navigateToCart(BuildContext context) {
    // ✅ Close the dialog and any PDPs
    Navigator.of(
      context,
      rootNavigator: true,
    ).popUntil((route) => route.isFirst);

    // ✅ Then open cart from bottom (85% height)
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cart",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.85, // 👈 85% of the screen
            widthFactor: 1.0,
            child: const CartScreen(),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // 👇 smooth slide up transition
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // from bottom
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ Product Image (big + animated)
              ScaleTransition(
                scale: _imageScale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.imageUrl!,
                          width: screenWidth * 0.55,
                          height: screenWidth * 0.55,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image_outlined,
                          size: screenWidth * 0.5,
                          color: Colors.grey.shade400,
                        ),
                ),
              ),
              const SizedBox(height: 30),

              // Product name
              Text(
                widget.itemName,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 🪩 "Item Added to Cart" text pop
              ScaleTransition(
                scale: _textScale,
                child: const Text(
                  "Item Added to Cart",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),

              // ✅ Animated green circle + check
              AnimatedBuilder(
                animation: _circleScale,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: _circleScale.value,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      AnimatedCheck(
                        progress: _checkAnimation,
                        size: 120,
                        color: Colors.green,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 70),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _closeAll(context);
                        widget.onContinue?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Continue Shopping",

                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 34,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _closeAll(context);
                        _navigateToCart(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2E8E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "View Cart & Pay",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 34,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
