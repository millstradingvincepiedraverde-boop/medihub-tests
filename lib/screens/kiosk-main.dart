import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
    imageUrl: 'assets/images/splash_3.png',
    title: 'Mobility Scooters',
    subtitle: 'We offer wide range of styles and sizes.',
    promoText: 'Delivered Today',
  ),
  SlideData(
    imageUrl: 'assets/images/splash_1.png',
    title: 'Wheelchairs',
    subtitle: 'We offer wide range of styles and sizes.',
    promoText: 'Delivered Today',
  ),
  SlideData(
    imageUrl: 'assets/images/splash_2.png',
    title: 'Bed Frames',
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProductCatalogScreen()),
    );
  }

  // --- Responsive helpers ---
  bool _isMobile(Size size) => size.width < 600;
  bool _isTablet(Size size) => size.width >= 600 && size.width < 1024;
  bool _isDesktop(Size size) => size.width >= 1024;

  double _scaleFont(double base, Size size) {
    if (_isMobile(size)) return base * 0.45;
    if (_isTablet(size)) return base * 0.75;
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

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: Container(color: Colors.white)),

        // --- Text content ---
        Positioned(
          top: isMobile
              ? size.height * 0.10
              : isTablet
              ? size.height * 0.1
              : size.height * 0.12,
          left: isMobile ? 20 : size.width * 0.1,
          right: isMobile ? 20 : size.width * 0.1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size.width * 0.9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/images/medihub-logo.svg',
                  height: isMobile
                      ? 24
                      : isTablet
                      ? 32
                      : 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                // --- Title ---
                Text(
                  slide.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: _scaleFont(90, size),
                    color: const Color(0xFF191919),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),

                // --- Subtitle ---
                Text(
                  slide.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: _scaleFont(28, size),
                    color: const Color(0xFF191919),
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 28),

                // --- Promo text ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  color: const Color(0xFF4A306D),
                  child: Text(
                    slide.promoText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: _scaleFont(26, size),
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- Product Image ---
        Positioned(
          right: isMobile
              ? 0
              : isTablet
              ? size.width * 0.02
              : size.width * 0.08,
          bottom: isMobile
              ? size.height * 0.08
              : isTablet
              ? size.height * 0.1
              : size.height * 0.12,
          child: Image.asset(
            slide.imageUrl,
            width: isMobile
                ? size.width * 1
                : isTablet
                ? size.width * 0.65
                : size.width * 0.55,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('⚠️ Image load failed: $error');
              return const Icon(Icons.error, color: Colors.red);
            },
          ),
        ),
      ],
    );
  }

  // --- Footer ---
  Widget _buildFooter(Size size) {
    final isMobile = _isMobile(size);
    final isTablet = _isTablet(size);

    return Positioned(
      bottom: 0,
      child: Container(
        width: size.width,
        height: isMobile
            ? 90
            : isTablet
            ? 140
            : 220,
        color: const Color(0xFF191919),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/touch-icon.svg',
                height: isMobile
                    ? 36
                    : isTablet
                    ? 80
                    : 120,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: isMobile ? 20 : 40),
              Flexible(
                child: Text(
                  'Touch to Order',
                  overflow: TextOverflow.fade,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isMobile
                        ? 26
                        : isTablet
                        ? 40
                        : 56,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Timeline ---
  Widget _buildTimeline(Size size) {
    final double bottomOffset = _isMobile(size)
        ? 90.0
        : _isTablet(size)
        ? 140.0
        : 220.0;

    return Positioned(
      bottom: bottomOffset,
      left: 0,
      child: Container(
        width: size.width,
        height: 5,
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
              height: 5,
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
      backgroundColor: Colors.white,
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
