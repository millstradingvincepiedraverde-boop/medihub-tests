import 'package:flutter/material.dart';

class VideoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const VideoButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Move the entire thing down and right a bit
      padding: const EdgeInsets.only(top: 20, left: 28),
      child: Align(
        alignment: Alignment.topLeft,
        child: GestureDetector(
          onTap: onPressed,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 🎞️ Base container (slightly bigger)
              Container(
                padding: const EdgeInsets.only(
                  left: 28,
                  top: 18,
                  bottom: 18,
                  right: 80, // More space for larger play button
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(45),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Video',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                    letterSpacing: 0.4,
                  ),
                ),
              ),

              // ▶️ Larger, lower play button
              Positioned(
                right: -16, // push slightly more out to the right
                top: -2, // move a little lower
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A3D66),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
