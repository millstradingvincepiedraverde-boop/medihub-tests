import 'package:flutter/material.dart';
import '../models/product.dart';
import '../constants/app_constants.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 🧩 Reduce space between cards
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 🧱 Card container
          Card(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                // 🩶 Reduced bottom padding to remove blank area
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🖼 Product image (slightly taller)
                    AspectRatio(
                      aspectRatio: 1, // makes image box more square
                      child: Hero(
                        tag: 'product_${product.id}',
                        child: Image.asset(
                          product.imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 🏷 Product name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // 💰 Price
                    Text(
                      '${AppConstants.currencySymbol}${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🎀 “Delivered Today” banner outside card
          if (product.hasSameDayDelivery)
            Positioned(
              top: 8,
              left: -6,
              child: CustomPaint(
                painter: BannerPainter(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: const Text(
                    'Delivered Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 🎨 Custom Painter for folded banner
class BannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A306D)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - 10, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 10, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Folded black tip
    final foldPaint = Paint()..color = Colors.black;
    final fold = Path();
    fold.moveTo(0, 0);
    fold.lineTo(6, size.height / 2);
    fold.lineTo(0, size.height);
    fold.close();
    canvas.drawPath(fold, foldPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
