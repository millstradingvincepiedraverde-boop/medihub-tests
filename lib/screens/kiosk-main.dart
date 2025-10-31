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

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Container(color: Colors.white), // ✅ WHITE BACKGROUND
        ),

        // --- Text content ---
        Positioned(
          top: isMobile
              ? size.height *
                    0.03 // 👈 close to top on mobile
              : size.height * 0.08, // 👈 slightly lower on larger screens
          left: isMobile ? 20 : size.width * 0.1,
          right: isMobile ? 10 : size.width * 0.1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size.width * 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/images/medihub-logo.svg',
                  height: isMobile
                      ? 20
                      : isTablet
                      ? 26
                      : 32,
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) =>
                      const CircularProgressIndicator(),
                ),
                const SizedBox(height: 24),

                // --- Title ---
                Text(
                  slide.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: _scaleFont(120, size), // ⬆️ Larger title
                    color: const Color(0xFF191919),
                    fontWeight: FontWeight.w800, // ⬆️ Bolder
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 20),

                // --- Subtitle ---
                Text(
                  slide.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: _scaleFont(32, size), // ⬆️ Slightly larger
                    color: const Color(0xFF191919),
                    fontWeight: FontWeight.w300, // Medium weight for clarity
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 36),

                // --- Promo text ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  color: const Color(0xFF4A306D),
                  child: Text(
                    slide.promoText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: _scaleFont(
                        32,
                        size,
                      ), // ⬆️ Slightly larger promo
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- Product Image (large) ---
        Positioned(
          right: isMobile ? -size.width * 1.7 : -size.width * 0.0,
          bottom: isMobile
              ? size.height * 0.60
              : isTablet
              ? size.height * 0.12
              : size.height * 0.13,
          child: Image.asset(
            slide.imageUrl,
            width: isMobile
                ? size.width * .99
                : isTablet
                ? size.width * .99
                : size.width * .99,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print('⚠️ Image load failed: $error');
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
    _scaleFont(46, size);

    return Positioned(
      bottom: 0,
      child: Container(
        width: size.width,
        height: isMobile ? 110 : 250,
        color: const Color(0xFF191919),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Corrected icon path
              SvgPicture.asset(
                'assets/icons/touch-icon.svg',
                height: isMobile ? 40 : 120,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 40),
              Text(
                'Touch to Order',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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
      bottom: _isMobile(size) ? 110 : 250,
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
      backgroundColor: Colors.white, // ✅ WHITE PAGE BACKGROUND
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
