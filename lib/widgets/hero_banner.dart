import 'package:flutter/material.dart';

class HeroBanner extends StatelessWidget {
  final double screenWidth;

  const HeroBanner({super.key, required this.screenWidth});

  static const double _kTabletBreakpoint = 800.0;

  @override
  Widget build(BuildContext context) {
    final bannerHeight = screenWidth * 0.35 > 250 ? 250.0 : screenWidth * 0.35;
    final padding = screenWidth > _kTabletBreakpoint ? 24.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      child: Container(
        height: bannerHeight,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 71, 3, 88),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 100, 50, 150).withOpacity(0.9),
              const Color.fromARGB(255, 71, 3, 88),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              bottom: -50,
              child: Icon(
                Icons.healing_outlined,
                size: bannerHeight * 1.1,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding * 1.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Featured Aid: The Ergonomic Walker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Experience enhanced mobility with our top-rated lightweight aluminum walker. Limited-time offer: 20% off all mobility aids!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Add navigation or callback logic here if needed
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 71, 3, 88),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('Shop the Offer Now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
