import 'package:flutter/material.dart';
import '../../models/postage_rate.dart';
import 'checkout_theme.dart';

class OrderSummary extends StatelessWidget {
  final List cartItems;
  final double subtotal;
  final List<PostageRate> rates;
  final String deliveryMethod;
  final bool isMobile;
  final VoidCallback onEditCart;

  const OrderSummary({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.rates,
    required this.deliveryMethod,
    required this.isMobile,
    required this.onEditCart,
  });

  @override
  Widget build(BuildContext context) {
    final selectedRate = rates.firstWhere(
      (r) => r.service.toLowerCase() == deliveryMethod,
      orElse: () => PostageRate(
        service: 'Standard',
        eta: '',
        cost: 0.0,
        code: '',
        sku: '',
      ),
    );
    final grandTotal = subtotal + selectedRate.cost;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Summary',
                style: TextStyle(
                  fontFamily: CheckoutTheme.fontFamily,
                  fontSize: isMobile ? 20 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onEditCart,
                child: const Text(
                  'Edit Cart',
                  style: TextStyle(color: CheckoutTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...cartItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.product.name ?? 'Product',
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('\$${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping'),
              Text(
                selectedRate.cost == 0
                    ? 'FREE'
                    : '\$${selectedRate.cost.toStringAsFixed(2)}',
                style: TextStyle(
                  color: selectedRate.cost == 0
                      ? CheckoutTheme.primaryColor
                      : const Color(0xFF191919),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CheckoutTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
