import 'package:flutter/material.dart';
import 'package:medihub_tests/models/product.dart';

class MobileCategoryChips extends StatelessWidget {
  final ProductCategory? selectedCategory;
  final Function(ProductCategory?) onCategorySelected;

  const MobileCategoryChips({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade50,
      height: 60,
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // All Products Chip
            _CategoryChip(
              label: 'All Products',
              isSelected: selectedCategory == null,
              onTap: () => onCategorySelected(null),
            ),
            const SizedBox(width: 8),

            // Other Category Chips
            ...ProductCategory.values.map((category) {
              final tempProduct = Product(
                id: '',
                sku: '',
                name: '',
                description: '',
                category: category,
                subType: '',
                price: 0,
                imageUrl: '',
                features: [],
                stockQuantity: 0,
                color: Colors.grey,
                colorName: '',
              );
              return Row(
                children: [
                  _CategoryChip(
                    label: tempProduct.categoryDisplayName,
                    isSelected: selectedCategory == category,
                    onTap: () => onCategorySelected(category),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      avatar: isSelected
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
      backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
        ),
      ),
      onPressed: onTap,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }
}
