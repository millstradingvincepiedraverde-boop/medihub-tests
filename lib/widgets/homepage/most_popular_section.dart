import 'package:flutter/material.dart';
import 'package:medihub_tests/models/product.dart';
import 'package:medihub_tests/widgets/homepage/popular_product_card.dart';

class MostPopularSection extends StatelessWidget {
  final List<Product> products;
  final Function(Product)? onProductTap;

  const MostPopularSection({
    Key? key,
    required this.products,
    this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayProducts = products.take(3).toList();

    return Container(
      width: double.infinity,
      color: const Color(0xFFE8D4F8),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Most Popular',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayProducts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final product = displayProducts[index];
                return PopularProductCard(
                  product: product,
                  badgeIndex: index,
                  onTap: onProductTap != null
                      ? () => onProductTap!(product)
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Carousel indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index == 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
