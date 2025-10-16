import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/order_service.dart';
import '../../utils/snackbar_helper.dart';
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

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    double imageSize = isWide
        ? size.width * 0.25
        : isTablet
        ? size.width * 0.35
        : size.width * 0.6;

    double buttonPadding = isWide ? 28 : 20;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // === TOP SECTION (Image, Name, Price, Controls) ===
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide
                      ? 80
                      : isTablet
                      ? 40
                      : 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // === IMAGE ===
                    _buildImage(p, imageSize),
                    const SizedBox(height: 24),

                    // === NAME & PRICE ===
                    Text(
                      p.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isWide
                            ? 32
                            : isTablet
                            ? 22
                            : 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF191919),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${AppConstants.currencySymbol}${p.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: isWide ? 48 : 32,
                        fontWeight: FontWeight.w900,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // === QUANTITY + ADD TO CART ===
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        // --- Quantity Controls ---
                        Container(
                          decoration: BoxDecoration(
                           
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 28,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() => _quantity++),
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- Add to Cart Button ---
                        ElevatedButton(
                          onPressed: () {
                            for (int i = 0; i < _quantity; i++) {
                              _orderService.addToCart(p);
                            }
                            SnackbarHelper.showSnackBar(
                              context,
                              message: '${p.name} added to cart ×$_quantity',
                              backgroundColor: Colors.deepPurple,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              225,
                              60,
                              1,
                              95,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: buttonPadding * 2,
                              vertical: buttonPadding,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'ADD TO CART',
                            style: TextStyle(
                              fontSize: isWide ? 20 : 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // === BLACK DETAILS SECTION (Full Width, No Outer Padding) ===
              Container(
                width: double.infinity,
                color: const Color(0xFF191919),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideLayout = constraints.maxWidth > 700;
                    return isWideLayout
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildLeftColumn(p)),
                              const SizedBox(width: 24),
                              Expanded(child: _buildRightColumn()),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLeftColumn(p),
                              const SizedBox(height: 24),
                              _buildRightColumn(),
                            ],
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === IMAGE SECTION ===
  Widget _buildImage(Product p, double size) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade100,
              image: DecorationImage(
                image: NetworkImage(p.imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, size: 28, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  // === LEFT COLUMN ===
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
            color: Colors.white,
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

  // === RIGHT COLUMN ===
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

  // === INFO BOXES ===
  Widget _infoBox(List<String> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white30),
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
        border: Border.all(color: Colors.white30),
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
