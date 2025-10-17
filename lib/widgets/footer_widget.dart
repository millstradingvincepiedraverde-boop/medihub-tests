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
    final isLargeScreen = screenWidth >= 800;

    return Container(
      color: const Color(0xFF1A171B),
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 40 : 16,
        vertical: 10,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // === Fixed Centered Links ===
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
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

          // === Fixed Left Volume Controls ===
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
                  width: isLargeScreen ? 180 : 120, // wider responsive slider
                  child: Slider(
                    value: _volume,
                    onChanged: (v) => setState(() => _volume = v),
                    activeColor: const Color(0xFF4A306D),
                    inactiveColor: Colors.white,
                    thumbColor: Colors.white,
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
      width: 32,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
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
