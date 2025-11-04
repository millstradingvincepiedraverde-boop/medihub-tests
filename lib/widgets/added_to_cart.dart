import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'cart_bottom_sheet_widget.dart';

class ItemAddedDialog extends StatefulWidget {
  final String itemName;
  final String? imageUrl;
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
  late AnimationController _imageController;
  late AnimationController _textController;
  late AnimationController _lottieController;
  late Animation<double> _imageScale;
  late Animation<double> _textScale;
  bool _showLottie = false;

  @override
  void initState() {
    super.initState();

    // 🖼️ Image "pop" animation (faster, tighter curve)
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _imageScale = CurvedAnimation(
      parent: _imageController,
      curve: Curves.easeOutBack,
    );

    // 🪩 Text "pop" animation (starts with image)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _textScale = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    );

    // 🎞️ Lottie animation controller
    _lottieController = AnimationController(vsync: this);

    // 🚀 Start all together (no long delays)
    _startSequence();
  }

  Future<void> _startSequence() async {
    if (!mounted) return;
    // Start image & text simultaneously
    _imageController.forward();
    _textController.forward();

    // Show Lottie quickly after a short delay (syncs with pop)
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() => _showLottie = true);
  }

  @override
  void dispose() {
    _imageController.dispose();
    _textController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  void _closeAll(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).maybePop();
  }

  void _navigateToCart(BuildContext context) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).popUntil((route) => route.isFirst);

    // Small delay ensures the stack stabilizes
    Future.delayed(const Duration(milliseconds: 80), () {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "Cart",
        barrierColor: Colors.black.withOpacity(0.45),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.85,
              widthFactor: 1.0,
              child: const CartBottomSheet(),
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
                begin: const Offset(0, 0.95),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
    });
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
              // 🖼️ Animated product image
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

              // 🪩 "Item Added to Cart" text
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
              const SizedBox(height: 30),

              // 🎞️ Lottie animation (success)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                child: _showLottie
                    ? Lottie.asset(
                        'assets/animations/lottie-check.json',
                        key: const ValueKey('lottie-check'),
                        controller: _lottieController,
                        onLoaded: (composition) {
                          if (mounted) {
                            _lottieController
                              ..duration = composition.duration
                              ..forward();
                          }
                        },
                        width: 160,
                        height: 160,
                        repeat: false,
                      )
                    : const SizedBox(height: 160),
              ),

              const SizedBox(height: 50),

              // 🛍️ Buttons
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
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Continue Shopping",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 26,
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
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "View Cart & Pay",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 26,
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
