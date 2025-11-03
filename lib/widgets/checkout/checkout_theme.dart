import 'package:flutter/material.dart';

class CheckoutTheme {
  static const Color primaryColor = Color(0xFF4A306D);
  static const String fontFamily = 'Poppins';
  
  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        color: Colors.black54,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}