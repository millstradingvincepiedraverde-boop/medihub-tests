import 'package:flutter/material.dart';

class FooterWidget extends StatefulWidget {
  const FooterWidget({super.key});

  @override
  State<FooterWidget> createState() => _FooterWidgetState();
}

class _FooterWidgetState extends State<FooterWidget> {
  double _volume = 0.5;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen =
        screenWidth >= 800; // ✅ show volume only on large screens

    return Container(
      width: double.infinity,
      color: const Color(0xFF1A171B),
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 40 : 16,
        vertical: 12,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // === Centered Footer Links ===
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: isLargeScreen ? 40 : 20,
              runSpacing: 8,
              children: const [
                Text(
                  'Privacy Policy',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text(
                  'Terms of Service',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text(
                  'Help Center',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),

          // === Left Volume Control Section (Only Large Screens) ===
          if (isLargeScreen)
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.volume_up, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  _buildSmallIconButton(Icons.remove, () {
                    setState(() {
                      _volume = (_volume - 0.1).clamp(0.0, 1.0);
                    });
                  }),
                  SizedBox(
                    width: 160,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                      ),
                      child: Slider(
                        value: _volume,
                        onChanged: (v) => setState(() => _volume = v),
                        activeColor: const Color(0xFF4A306D),
                        inactiveColor: Colors.white54,
                        thumbColor: Colors.white,
                      ),
                    ),
                  ),
                  _buildSmallIconButton(Icons.add, () {
                    setState(() {
                      _volume = (_volume + 0.1).clamp(0.0, 1.0);
                    });
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 30,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 16,
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }
}
