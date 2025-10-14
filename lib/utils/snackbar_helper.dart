import 'package:flutter/material.dart';

class SnackbarHelper {
  static void showSnackBar(
    BuildContext context, {
    required String message,
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: behavior,
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}