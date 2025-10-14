// lib/widgets/suggestion_card.dart

import 'package:flutter/material.dart';
import '../models/product.dart';

class SuggestionCard extends StatelessWidget {
  final Product product;
  final String suggestionType; // e.g., 'Alternative' or 'Upgrade'
  final VoidCallback onTap;
  
  const SuggestionCard({
    super.key,
    required this.product,
    required this.suggestionType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Suggestion Type Label
            Text(
              suggestionType,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: suggestionType == 'Alternative' 
                    ? Colors.purple 
                    : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 4),
            
            // Product Image (Placeholder)
            Center(
              child: Container(
                height: 50,
                width: 50,
                color: product.color.withOpacity(0.1),
                child: Icon(Icons.medical_services_outlined, color: product.color),
              ),
            ),
            const SizedBox(height: 8),

            // Product Name and Price
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}