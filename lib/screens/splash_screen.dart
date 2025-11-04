import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/product_controller.dart';
import '../services/preload_service.dart';
import 'kiosk-main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  PreloadService? _preloadService;
  bool _isPreloading = true;
  double _progress = 0.0;
  String _loadingMessage = 'Initializing...';
  late AnimationController _pulseController;
  DateTime? _startTime;
  final Duration _minSplashDuration = const Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startPreloading();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Start preloading data and images
  void _startPreloading() {
    final productController = context.read<ProductController>();
    _preloadService = PreloadService(productController);

    // Update progress periodically
    _updateProgress();

    _preloadService!.preloadAll(context).then((_) {
      if (mounted) {
        final elapsed = DateTime.now().difference(_startTime!);
        final remaining = _minSplashDuration - elapsed;

        // Wait for minimum splash duration if preload completed too quickly
        if (remaining.inMilliseconds > 0) {
          setState(() {
            _loadingMessage = 'Almost ready...';
            _progress = 1.0;
          });
          Future.delayed(remaining, () {
            if (mounted) {
              _navigateToMain();
            }
          });
        } else {
          setState(() {
            _loadingMessage = 'Almost ready...';
            _progress = 1.0;
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _navigateToMain();
            }
          });
        }
      }
    }).catchError((error) {
      if (mounted) {
        // Even if preload fails, allow navigation after minimum time
        final elapsed = DateTime.now().difference(_startTime!);
        final remaining = _minSplashDuration - elapsed;

        setState(() {
          _loadingMessage = 'Loading...';
        });

        Future.delayed(
            remaining.inMilliseconds > 0 ? remaining : Duration.zero, () {
          if (mounted) {
            _navigateToMain();
          }
        });
      }
    });
  }

  /// Update progress indicator periodically
  void _updateProgress() {
    if (!mounted || !_isPreloading) return;

    final progress = _preloadService?.progress ?? 0.0;
    final currentProgress = progress;

    if (currentProgress < 0.25) {
      _loadingMessage = 'Loading products...';
    } else if (currentProgress < 0.5) {
      _loadingMessage = 'Loading categories...';
    } else if (currentProgress < 0.75) {
      _loadingMessage = 'Caching images...';
    } else if (currentProgress < 1.0) {
      _loadingMessage = 'Finalizing...';
    } else {
      _loadingMessage = 'Ready!';
    }

    if (mounted) {
      setState(() {
        _progress = currentProgress;
      });
    }

    // Continue updating every 200ms while loading
    if (_isPreloading && mounted) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _updateProgress();
      });
    }
  }

  /// Navigate to main kiosk screen
  void _navigateToMain() {
    if (!mounted) return;

    setState(() {
      _isPreloading = false;
    });

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const KioskMain(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  bool _isMobile(Size size) => size.width < 600;
  bool _isTablet(Size size) => size.width >= 600 && size.width < 1024;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = _isMobile(size);
    final isTablet = _isTablet(size);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient or solid color
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    const Color(0xFFF8F9FA),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with pulse animation
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.05),
                      child: Opacity(
                        opacity: 0.9 + (_pulseController.value * 0.1),
                        child: SvgPicture.asset(
                          'assets/images/medihub-logo.svg',
                          height: isMobile ? 80 : isTablet ? 120 : 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Loading message
                Text(
                  _loadingMessage,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isMobile ? 18 : isTablet ? 22 : 26,
                    color: const Color(0xFF191919),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Progress indicator
                SizedBox(
                  width: isMobile ? size.width * 0.6 : size.width * 0.4,
                  child: Column(
                    children: [
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 4,
                          backgroundColor: const Color(0xFFE8D7F1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF4A306D),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Progress percentage
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isMobile ? 14 : 16,
                          color: const Color(0xFF666666),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom tagline (optional)
          Positioned(
            bottom: isMobile ? 40 : 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Your trusted mobility solutions partner',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isMobile ? 12 : 14,
                  color: const Color(0xFF999999),
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

