import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'catalog/product_catalog_screen.dart';

// --- Slide Model ---
class SlideData {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String promoText;

  SlideData({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.promoText,
  });
}

// --- Slides ---
final List<SlideData> slides = [
  SlideData(
    imageUrl:
        'https://cdn.shopify.com/s/files/1/0698/0822/6356/files/HECWLCEQB2BL.png?v=1755583451',
    title: 'Wheelchairs',
    subtitle: 'We offer wide range of styles and sizes.',
    promoText: 'Delivered Today',
  ),
  SlideData(
    imageUrl:
        'https://cdn.shopify.com/s/files/1/0698/0822/6356/files/AGCMSCEMQA2BL.png?v=1755583451',
    title: 'Mobility Scooters',
    subtitle: 'We offer wide range of styles and sizes.',
    promoText: 'Delivered Today',
  ),
];

class KioskMain extends StatefulWidget {
  const KioskMain({super.key});

  @override
  State<KioskMain> createState() => _KioskMainState();
}

class _KioskMainState extends State<KioskMain> with TickerProviderStateMixin {
  int _currentSlideIndex = 0;
  Timer? _slideTimer;
  late AnimationController _timelineController;

  final Duration _slideDuration = const Duration(seconds: 6);
  final Duration _animationDuration = const Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    if (slides.isEmpty) return;

    _timelineController = AnimationController(
      vsync: this,
      duration: _slideDuration,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startSlideshow();
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _timelineController.dispose();
    super.dispose();
  }

  void _startSlideshow() {
    if (!mounted || slides.isEmpty) return;

    _timelineController.forward(from: 0.0);
    _slideTimer?.cancel();

    _slideTimer = Timer(_slideDuration, () {
      if (!mounted || slides.isEmpty) return;
      setState(() {
        _currentSlideIndex = (_currentSlideIndex + 1) % slides.length;
      });
      _startSlideshow();
    });
  }

  void _toggleKiosk() {
    _slideTimer?.cancel();
    _timelineController.stop();

    // Instantly navigate to the catalog (no animation delay)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProductCatalogScreen()),
    );
  }

  // --- Responsive helpers ---
  bool _isMobile(Size size) => size.width < 600;
  bool _isTablet(Size size) => size.width >= 600 && size.width < 1024;

  double _scaleFont(double base, Size size) {
    if (_isMobile(size)) return base * 0.5;
    if (_isTablet(size)) return base * 0.8;
    return base;
  }

  // --- Slideshow ---
  Widget _buildSlideshow(Size size) {
    if (slides.isEmpty || _currentSlideIndex >= slides.length) {
      return const Center(child: Text('No slides available'));
    }

    final slide = slides[_currentSlideIndex];
    final isMobile = _isMobile(size);
    final isTablet = _isTablet(size);

    final double imageWidth = isMobile
        ? size.width * 0.8
        : isTablet
        ? size.width * 0.5
        : size.width * 0.4;

    final double textTop = isMobile
        ? size.height * 0.15
        : isTablet
        ? size.height * 0.2
        : size.height * 0.25;

    final double sidePadding = isMobile ? 20 : size.width * 0.1;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: Container(color: const Color(0xFFF5F5F5))),

        // --- Text content ---
        Positioned(
          top: textTop,
          left: sidePadding,
          right: sidePadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size.width * 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.network(
                  'https://cdn.shopify.com/s/files/1/0698/0822/6356/files/logo.svg?v=1755583753',
                  height: isMobile
                      ? 16
                      : isTablet
                      ? 20
                      : 26,
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) =>
                      const CircularProgressIndicator(),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  slide.title,
                  style: TextStyle(
                    fontSize: _scaleFont(60, size),
                    color: const Color(0xFF191919),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  slide.subtitle,
                  style: TextStyle(
                    fontSize: _scaleFont(24, size),
                    color: const Color(0xFF191919),
                  ),
                ),
                const SizedBox(height: 32),

                // Promo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  color: const Color(0xFF4A306D),
                  child: Text(
                    slide.promoText,
                    style: TextStyle(
                      fontSize: _scaleFont(26, size),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- Product Image ---
        Positioned(
          right: isMobile ? size.width * 0.1 : size.width * 0.05,
          top: isMobile ? size.height * 0.45 : size.height * 0.25,
          child: Image.network(
            slide.imageUrl,
            width: imageWidth,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  // --- Footer ---
  Widget _buildFooter(Size size) {
    final isMobile = _isMobile(size);
    final fontSize = _scaleFont(42, size);

    return Positioned(
      bottom: 0,
      child: Container(
        width: size.width,
        height: isMobile ? 80 : 120,
        color: const Color(0xFF191919),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app,
                color: Colors.white,
                size: isMobile ? 40 : 60,
              ),
              const SizedBox(width: 20),
              Text(
                'Touch to order',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Timeline bar ---
  Widget _buildTimeline(Size size) {
    return Positioned(
      bottom: _isMobile(size) ? 80 : 120,
      left: 0,
      child: Container(
        width: size.width,
        height: 6,
        color: const Color(0xFFE8D7F1),
        child: AnimatedBuilder(
          animation: _timelineController,
          builder: (context, child) => Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width:
                  size.width *
                  (_timelineController.isAnimating
                      ? _timelineController.value
                      : 0.0),
              height: 6,
              color: const Color(0xFF4A306D),
            ),
          ),
        ),
      ),
    );
  }

  // --- Build ---
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: GestureDetector(
        onTap: _toggleKiosk,
        child: Stack(
          children: [
            _buildSlideshow(size),
            _buildTimeline(size),
            _buildFooter(size),
          ],
        ),
      ),
    );
  }
}
