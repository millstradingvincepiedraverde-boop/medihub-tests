import 'package:flutter/material.dart';
import 'checkout_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final bool isMobile;

  const SectionTitle(this.title, {super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: CheckoutTheme.fontFamily,
        fontSize: isMobile ? 22 : 26,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF191919),
      ),
    );
  }
}
