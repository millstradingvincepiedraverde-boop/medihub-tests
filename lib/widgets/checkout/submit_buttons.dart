import 'package:flutter/material.dart';
import 'checkout_theme.dart';

class SubmitButtons extends StatelessWidget {
  final VoidCallback onSubmit;

  const SubmitButtons({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: CheckoutTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Pay now on terminal',
              style: TextStyle(
                fontFamily: CheckoutTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: OutlinedButton(
            onPressed: onSubmit,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: CheckoutTheme.primaryColor,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Pay later with NDIS',
                  style: TextStyle(
                    fontFamily: CheckoutTheme.fontFamily,
                    fontSize: 16,
                    color: CheckoutTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 36,
                  height: 22,
                  child: Center(
                    child: Text(
                      'ndis',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
