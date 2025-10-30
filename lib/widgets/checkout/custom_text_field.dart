import 'package:flutter/material.dart';
import 'checkout_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      decoration: CheckoutTheme.inputDecoration(label),
      style: const TextStyle(
        fontFamily: CheckoutTheme.fontFamily,
        fontSize: 16,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
