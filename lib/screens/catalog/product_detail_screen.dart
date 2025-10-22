import 'package:flutter/material.dart';
// kept for optional future use
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
  int _currentImage = 0;

  // If you later have multiple images per product, replace this list with them.
  late final List<String> galleryImages;
  final ScrollController _thumbScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Use main image only by default (no _1/_2 suffixing)
    final main = widget.product.imageUrl;
    galleryImages = [main]; // keep single image for now — replace with real list when available
  }

  @override
  void dispose() {
    _thumbScrollController.dispose();
    super.dispose();
  }

  // helper to scroll thumbnails so tapped index is visible/centered
  void _scrollThumbsToIndex(int index, double thumbWidth, double spacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset =
        (index * (thumbWidth + spacing)) - (screenWidth / 2) + (thumbWidth / 2);
    final clamped = targetOffset.clamp(
      _thumbScrollController.position.minScrollExtent,
      _thumbScrollController.position.maxScrollExtent,
    );
    _thumbScrollController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 1000;
          final isTablet =
              constraints.maxWidth > 600 && constraints.maxWidth <= 1000;

          double imageSize = isWide
              ? constraints.maxWidth * 0.25
              : isTablet
                  ? constraints.maxWidth * 0.4
                  : constraints.maxWidth * 0.7;

          double horizontalPadding = isWide ? 120 : (isTablet ? 40 : 16);
          double fontTitle = isWide ? 32 : (isTablet ? 22 : 16);
          double priceFont = isWide ? 48 : (isTablet ? 36 : 28);

          // thumbnail sizing (compact)
          final double thumbWidth = isWide ? 160 : (isTablet ? 120 : 88);
          final double thumbSpacing = 8.0;
          final thumbHeight = thumbWidth * 0.7;

          return Stack(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // === TOP SECTION ===
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: isWide ? 60 : 40,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // === MAIN IMAGE ===
                              Hero(
                                tag: 'product_${p.id}',
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Image.network(
                                    galleryImages[_currentImage],
                                    key: ValueKey<int>(_currentImage),
                                    width: imageSize,
                                    height: imageSize,
                                    fit: BoxFit.contain, // preserves aspect ratio
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // === COMPACT THUMBNAIL STRIP (replaces the previous carousel for thumbnails) ===
                              // Keeps thumbnails compact & centered and avoids controller type issues.
                              if (galleryImages.isNotEmpty)
                                SizedBox(
                                  height: thumbHeight,
                                  child: Center(
                                    child: ListView.separated(
                                      controller: _thumbScrollController,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: (constraints.maxWidth -
                                                  (galleryImages.length *
                                                          (thumbWidth +
                                                              thumbSpacing) -
                                                      thumbSpacing)) /
                                              2 >
                                              0
                                              ? 0
                                              : 0),
                                      itemCount: galleryImages.length,
                                      separatorBuilder: (_, __) =>
                                          SizedBox(width: thumbSpacing),
                                      itemBuilder: (context, index) {
                                        final img = galleryImages[index];
                                        final selected = index == _currentImage;
                                        return GestureDetector(
                                          onTap: () {
                                            // update main image
                                            setState(() => _currentImage = index);
                                            // scroll strip so tapped thumb is centered/visible
                                            if (_thumbScrollController.hasClients) {
                                              _scrollThumbsToIndex(
                                                index,
                                                thumbWidth,
                                                thumbSpacing,
                                              );
                                            }
                                          },
                                          child: AnimatedContainer(
                                            duration:
                                                const Duration(milliseconds: 180),
                                            width: thumbWidth,
                                            height: thumbHeight,
                                            margin: EdgeInsets.symmetric(
                                                vertical: selected ? 0 : 6),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: selected
                                                    ? const Color(0xFF4A306D)
                                                    : Colors.grey.shade300,
                                                width: selected ? 2.6 : 1.4,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey.shade100,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Image.network(
                                                img,
                                                fit: BoxFit.cover,
                                                width: thumbWidth,
                                                height: thumbHeight,
                                                errorBuilder:
                                                    (context, error, stack) =>
                                                        Container(
                                                  color: Colors.grey[200],
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    color:
                                                        Colors.grey.shade400,
                                                    size: thumbWidth * 0.4,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 24),

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
                            ],
                          ),
                        ),

                        // === BLACK DETAILS SECTION (wide 2-column preserved) ===
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: const Color(0xFF191919),
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 100 : 24,
                              vertical: isWide ? 60 : 40,
                            ),
                            child: isWide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _buildLeftColumn(p)),
                                      const SizedBox(width: 40),
                                      Expanded(child: _buildRightColumn()),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLeftColumn(p),
                                      const SizedBox(height: 32),
                                      _buildRightColumn(),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // === FIXED CLOSE BUTTON ===
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
        }),
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
          IconButton(
            onPressed: () {
              if (_quantity > 1) setState(() => _quantity--);
            },
            icon: const Icon(Icons.remove_circle_outline, size: 28),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '$_quantity',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _quantity++),
            icon: const Icon(Icons.add_circle_outline, size: 28),
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
        SnackbarHelper.showSnackBar(
          context,
          message: '${p.name} added to cart ×$_quantity',
          backgroundColor: Colors.deepPurple,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A306D),
        padding: EdgeInsets.symmetric(
          horizontal: buttonPadding * 2,
          vertical: buttonPadding,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'ADD TO CART',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.white,
        ),
      ),
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

  // === INFO BOX ===
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

  // === TEXT INFO BOX ===
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
