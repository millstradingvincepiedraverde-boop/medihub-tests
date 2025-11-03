import 'package:flutter/material.dart';
import 'package:medihub_tests/widgets/added_to_cart.dart';
import 'package:medihub_tests/widgets/pdp/video_button.dart';

// kept for optional future use
import '../../models/product.dart';
import '../../services/order_service.dart';
import '../../constants/app_constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _orderService = OrderService();
  int _quantity = 1;
  int _currentImage = 0;

  late final List<String> galleryImages;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Replace with multiple images when available
    galleryImages = [
      widget.product.imageUrl,
      widget.product.imageUrl,
      widget.product.imageUrl,
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 1000;
            final isTablet =
                constraints.maxWidth > 600 && constraints.maxWidth <= 1000;

            double imageSize = isWide
                ? constraints.maxWidth * 0.4
                : isTablet
                ? constraints.maxWidth * 0.7
                : constraints.maxWidth * 0.9;

            double horizontalPadding = isWide ? 120 : (isTablet ? 40 : 16);
            double fontTitle = isWide ? 32 : (isTablet ? 22 : 16);
            double priceFont = isWide ? 48 : (isTablet ? 36 : 24);

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // === VIDEO BUTTON WITH TOP + LEFT PADDING ===
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 24.0,
                          left: 24.0,
                          bottom: 32.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: VideoButton(
                            onPressed: () {
                              // Your video button logic here
                            },
                          ),
                        ),
                      ),

                      // === MAIN IMAGE CAROUSEL ===
                      SizedBox(
                        height:
                            imageSize *
                            0.75, // 🔹 Slightly smaller (85% of previous size)
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Image carousel
                            PageView.builder(
                              onPageChanged: (index) {
                                setState(() => _currentImage = index);
                              },
                              itemCount: galleryImages.length,
                              itemBuilder: (context, index) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Image.network(
                                    galleryImages[index],
                                    key: ValueKey<int>(index),
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stack) =>
                                        Container(
                                          color: Colors.grey[200],
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey.shade400,
                                            size: 60,
                                          ),
                                        ),
                                  ),
                                );
                              },
                            ),

                            // Left arrow
                            Positioned(
                              left: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 32,
                                  color: Colors.black54,
                                ),
                                onPressed: () {
                                  if (_currentImage > 0) {
                                    setState(() => _currentImage--);
                                  }
                                },
                              ),
                            ),

                            // Right arrow
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 32,
                                  color: Colors.black54,
                                ),
                                onPressed: () {
                                  if (_currentImage <
                                      galleryImages.length - 1) {
                                    setState(() => _currentImage++);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Dots indicator
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: List.generate(
                      //     galleryImages.length,
                      //     (index) => Container(
                      //       width: 10,
                      //       height: 10,
                      //       margin: const EdgeInsets.symmetric(horizontal: 4),
                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,
                      //         color: _currentImage == index
                      //             ? const Color(0xFF4A306D)
                      //             : Colors.grey[300],
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      // === NAME + PRICE ===
                      Text(
                        p.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontTitle,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF191919),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppConstants.currencySymbol}${p.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: priceFont,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // === QUANTITY + ADD TO CART ===
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _quantityControl(),
                          _addToCartButton(p, isWide ? 28 : 20),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // === BLACK DETAILS SECTION ===
                      Container(
                        width: double.infinity,
                        color: const Color(0xFF191919),
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 100 : 24,
                          vertical: isWide ? 60 : 40,
                        ),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildLeftColumn(p)),
                                  const SizedBox(width: 40),
                                  Expanded(child: _buildRightColumn()),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLeftColumn(p),
                                  const SizedBox(height: 32),
                                  _buildRightColumn(),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),

                // Close button
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // === QUANTITY CONTROL ===
  Widget _quantityControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (_quantity > 1) setState(() => _quantity--);
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$_quantity',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => setState(() => _quantity++),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // === ADD TO CART BUTTON ===
  Widget _addToCartButton(Product p, double buttonPadding) {
    return ElevatedButton(
      onPressed: () {
        for (int i = 0; i < _quantity; i++) {
          _orderService.addToCart(p);
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ItemAddedDialog(
            itemName: '${p.name} ×$_quantity',
            onContinue: () {
              Navigator.of(context).pop();
            },
            onViewCart: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/cart');
            },
            imageUrl: p.imageUrl,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A306D),
        padding: EdgeInsets.symmetric(
          horizontal: buttonPadding * 6,
          vertical: buttonPadding,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Add to Cart',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.white,
        ),
      ),
    );
  }

  // === LEFT & RIGHT COLUMN REUSE ===
  Widget _buildLeftColumn(Product p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          p.description,
          style: const TextStyle(
            color: Colors.white70,
            height: 1.5,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Highlights",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        _infoBox([
          "12-month Australian warranty",
          "26cc two-stroke petrol engine",
          "270km/h blow speed",
          "Double-ringed piston",
          "Dual-weighted crankshaft",
          "Lightweight one-hand operation",
          "Two direction tubes",
          "CE, GS, EMC certification",
          "BONUS tool kit and fuel mixer",
        ]),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Specifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        _infoBoxText({
          "Top Speed": "8km/h",
          "Range": "30km",
          "Weight Capacity": "136kg",
          "Turning Radius": "1.2m",
          "Ground Clearance": "7.6cm",
          "Dimensions (LxWxH)": "102cm x 54cm x 91cm",
          "Weight": "38kg",
          "Battery": "12V x 2 (24V system)",
          "Charger": "Off-board, 2A",
        }),
        const SizedBox(height: 24),
        const Text(
          "In the Box",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        _infoBox(["1x User Manual", "1x Charger", "1x Tool Kit"]),
        const SizedBox(height: 24),
        const Text(
          "Size & Weight",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        _infoBoxText({
          "Gross Weight": "65kg",
          "Net Weight": "38kg",
          "Width": "54cm",
          "Length": "102cm",
          "Height": "91cm",
        }),
      ],
    );
  }

  Widget _infoBox(List<String> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _infoBoxText(Map<String, String> specs) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: specs.entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${e.key}: ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: e.value,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
