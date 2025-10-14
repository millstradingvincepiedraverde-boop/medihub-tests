import 'package:flutter/material.dart';
import '../models/order.dart';
import '../constants/app_constants.dart';

class CartItemWidget extends StatelessWidget {
  final OrderItem orderItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.orderItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: orderItem.product.color.withOpacity(0.1),
                image: DecorationImage(
                  image: NetworkImage(orderItem.product.imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderItem.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    orderItem.product.subTypeDisplayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppConstants.currencySymbol}${orderItem.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Quantity Controls
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (orderItem.quantity > 1) {
                          onQuantityChanged(orderItem.quantity - 1);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: orderItem.quantity > 1 ? Colors.blue : Colors.grey,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${orderItem.quantity}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (orderItem.quantity < orderItem.product.stockQuantity) {
                          onQuantityChanged(orderItem.quantity + 1);
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      color: orderItem.quantity < orderItem.product.stockQuantity
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${AppConstants.currencySymbol}${orderItem.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 8),
            
            // Remove Button
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}