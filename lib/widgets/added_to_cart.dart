import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../screens/cart/cart_screen.dart';

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

    // 🖼️ Image "pop" animation
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _imageScale = CurvedAnimation(
      parent: _imageController,
      curve: Curves.elasticOut,
    );

    // 🪩 Text "pop" animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textScale = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    );

    // 🎞️ Lottie animation controller
    _lottieController = AnimationController(vsync: this);

    // 🪄 Animation sequence
    _startSequence();
  }

  Future<void> _startSequence() async {
    // Image first
    if (!mounted) return;
    await _imageController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Then text
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Then show Lottie animation
    if (mounted) {
      setState(() => _showLottie = true);
    }
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

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cart",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.85,
            widthFactor: 1.0,
            child: const CartScreen(),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
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
              const SizedBox(height: 40),

              // 🎞️ Lottie animation (success)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeOutCubic,
                child: _showLottie
                    ? Lottie.asset(
                        'assets/animations/success.json',
                        key: const ValueKey('successLottie'),
                        controller: _lottieController,
                        onLoaded: (composition) {
                          if (mounted) {
                            _lottieController
                              ..duration = composition.duration
                              ..forward();
                          }
                        },
                        width: 180,
                        height: 180,
                        repeat: false,
                      )
                    : const SizedBox(height: 180),
              ),

              const SizedBox(height: 50),

              // Buttons
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
