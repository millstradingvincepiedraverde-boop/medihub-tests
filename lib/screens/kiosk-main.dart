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
  bool _isCollapsed = false;
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

  // --- Slide Logic ---
  void _startSlideshow() {
    if (!mounted || slides.isEmpty) return;

    _timelineController.forward(from: 0.0);
    _slideTimer?.cancel();

    _slideTimer = Timer(_slideDuration, () {
      if (!mounted || slides.isEmpty) return;
      setState(() {
        _currentSlideIndex =
            (_currentSlideIndex + 1) % slides.length; // Safe cycling
      });
      _startSlideshow();
    });
  }

  void _toggleKiosk() async {
    if (_isCollapsed) return;

    _slideTimer?.cancel();
    _timelineController.stop();

    setState(() => _isCollapsed = true);
    await Future.delayed(_animationDuration);

    if (mounted) _navigateToCatalog();
  }

  Future<void> _navigateToCatalog() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProductCatalogScreen()),
    );

    if (mounted) {
      setState(() => _isCollapsed = false);
    }
  }

  // --- UI ---
  Widget _buildSlideshow(Size size) {
    if (slides.isEmpty || _currentSlideIndex >= slides.length) {
      return const Center(child: Text('No slides available'));
    }

    final slide = slides[_currentSlideIndex];
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: Container(color: const Color(0xFFF5F5F5))),

        // --- Text content with logo ---
        AnimatedPositioned(
          duration: _animationDuration,
          curve: Curves.easeInOutCubic,
          top: _isCollapsed ? -200 : size.height * 0.25,
          left: size.width * 0.1,
          child: AnimatedOpacity(
            opacity: _isCollapsed ? 0.0 : 1.0,
            duration: _animationDuration,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: size.width * 0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.network(
                    'https://cdn.shopify.com/s/files/1/0698/0822/6356/files/logo.svg?v=1755583753',
                    height: 20,
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) =>
                        const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    slide.title,
                    style: const TextStyle(
                      fontSize: 60,
                      color: Color(0xFF191919),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    slide.subtitle,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF191919),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    color: const Color(0xFF4A306D),
                    child: Text(
                      slide.promoText,
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- Product image ---
        AnimatedPositioned(
          duration: _animationDuration,
          curve: Curves.easeInOutCubic,
          right: _isCollapsed ? -size.width : size.width * 0.05,
          top: size.height * 0.25,
          child: AnimatedOpacity(
            duration: _animationDuration,
            opacity: _isCollapsed ? 0.0 : 1.0,
            child: Image.network(
              slide.imageUrl,
              width: size.width * 0.4,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Size size) {
    return AnimatedPositioned(
      duration: _animationDuration,
      bottom: _isCollapsed ? -300 : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: _isCollapsed ? 0.0 : 1.0,
        child: Container(
          width: size.width,
          height: 120,
          color: const Color(0xFF191919),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.touch_app, color: Colors.white, size: 60),
                SizedBox(width: 20),
                Text(
                  'Touch to order',
                  style: TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(Size size) {
    return Positioned(
      bottom: 120,
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
