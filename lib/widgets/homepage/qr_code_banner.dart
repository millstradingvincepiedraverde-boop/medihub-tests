import 'package:flutter/material.dart';

class QRCodeBanner extends StatelessWidget {
  const QRCodeBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTextContent(centered: true),
                const SizedBox(height: 32),
                _buildQRCode(size: 180), // ✅ Larger QR code for mobile
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildTextContent(centered: false),
                ),
              ),
              const SizedBox(width: 64),
              _buildQRCode(size: 200), // ✅ Bigger QR code for desktop
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextContent({bool centered = false}) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Can’t decide on\nthe spot?",
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Scan the QR code and shop from your phone.',
          textAlign: centered ? TextAlign.center : TextAlign.right,
          style: TextStyle(color: Colors.grey[400], fontSize: 22, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildQRCode({double size = 180}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: Image.asset(
        'assets/icons/QRCode-Medihub.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
