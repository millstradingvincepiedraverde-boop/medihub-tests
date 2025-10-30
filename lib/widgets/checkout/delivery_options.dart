import 'package:flutter/material.dart';
import '../../models/postage_rate.dart';
import 'checkout_theme.dart';

class DeliveryOptions extends StatelessWidget {
  final bool isLoading;
  final List<PostageRate> rates;
  final String selectedMethod;
  final Function(String) onMethodChanged;

  const DeliveryOptions({
    super.key,
    required this.isLoading,
    required this.rates,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (rates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Enter your postcode to view delivery options.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      children: rates.map((rate) {
        final isSelected = selectedMethod == rate.service.toLowerCase();
        final parts = rate.service.split(' - ');
        final title = parts.isNotEmpty ? parts.first.trim() : rate.service;
        final subtitle = parts.length > 1 ? parts.last.trim() : '';
        final displayCost =
            (rate.service.toLowerCase().contains('on demand') &&
                rate.cost == 4.95)
            ? 0.0
            : rate.cost;
        final costText = displayCost == 0.0
            ? 'FREE'
            : '\$${displayCost.toStringAsFixed(2)}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => onMethodChanged(rate.service.toLowerCase()),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? CheckoutTheme.primaryColor.withOpacity(0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? CheckoutTheme.primaryColor
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: rate.service.toLowerCase(),
                    groupValue: selectedMethod,
                    onChanged: (val) => onMethodChanged(val ?? selectedMethod),
                    activeColor: CheckoutTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontFamily: CheckoutTheme.fontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontFamily: CheckoutTheme.fontFamily,
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          costText,
                          style: TextStyle(
                            fontFamily: CheckoutTheme.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: displayCost == 0.0
                                ? Colors.green.shade700
                                : const Color(0xFF191919),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
