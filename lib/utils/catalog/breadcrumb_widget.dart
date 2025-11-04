import 'package:flutter/material.dart';

class BreadcrumbWidget extends StatelessWidget {
  final List<String> breadcrumbPath;
  final Function(int) onBreadcrumbTap;

  const BreadcrumbWidget({
    Key? key,
    required this.breadcrumbPath,
    required this.onBreadcrumbTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: List.generate(breadcrumbPath.length, (index) {
          final label = breadcrumbPath[index];
          final isLast = index == breadcrumbPath.length - 1;

          Widget breadcrumbTile = GestureDetector(
            onTap: isLast ? null : () => onBreadcrumbTap(index),
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                  color: isLast
                      ? const Color(0xFF4A306D)
                      : Colors.grey.shade600,
                  decoration: isLast
                      ? TextDecoration.none
                      : TextDecoration.underline,
                  decorationColor: Colors.grey.shade400,
                ),
              ),
            ),
          );

          if (!isLast) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                breadcrumbTile,
                const Text(
                  ' > ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          }

          return breadcrumbTile;
        }),
      ),
    );
  }
}