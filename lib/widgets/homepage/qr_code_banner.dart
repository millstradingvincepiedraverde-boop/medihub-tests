import 'package:flutter/material.dart';

class QRCodeBanner extends StatelessWidget {
  const QRCodeBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return Column(
              children: [
                _buildTextContent(),
                const SizedBox(height: 24),
                _buildQRCode(),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextContent(),
              const SizedBox(width: 48),
              _buildQRCode(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Can't decide on\nthe spot?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Scan the QR code and shop from your phone.',
          style: TextStyle(color: Colors.grey[400], fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildQRCode() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.qr_code_2, size: 110, color: Colors.black),
      ),
    );
  }
}
