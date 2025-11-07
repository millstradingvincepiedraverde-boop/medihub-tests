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
                const SizedBox(height: 24),
                _buildQRCode(size: 130),
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
              const SizedBox(width: 48),
              _buildQRCode(size: 130),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextContent({bool centered = false}) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          "Can’t decide on\nthe spot?",
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white,
            fontSize: 48, // larger and bolder
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Scan the QR code and shop from your phone.',
          textAlign: centered ? TextAlign.center : TextAlign.right,
          style: TextStyle(color: Colors.grey[400], fontSize: 24, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildQRCode({double size = 130}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Icon(Icons.qr_code_2, size: 100, color: Colors.black),
      ),
    );
  }
}
