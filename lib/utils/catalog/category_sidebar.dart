import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:medihub_tests/controllers/product_controller.dart';
import 'package:medihub_tests/models/product.dart';
import 'package:medihub_tests/constants/app_constants.dart';

class CategorySidebar extends StatelessWidget {
  final ProductCategory? selectedCategory;
  final dynamic selectedSubType;
  final Function(ProductCategory?) onCategorySelected;

  const CategorySidebar({
    Key? key,
    required this.selectedCategory,
    required this.selectedSubType,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF4A306D);

    return Container(
      width: 320,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Header
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(color: Colors.white),
            child: SvgPicture.asset(
              'assets/images/medihub-logo.svg',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),

          // Category List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Divider(
                    height: 1,
                    color: Color.fromARGB(255, 230, 230, 230),
                  ),
                ),

                // Dynamic Categories
                ...ProductCategory.values.map((category) {
                  final productController = context.watch<ProductController>();
                  final products = productController.getProductsByCategory(
                    category,
                  );
                  final count = products.length;

                  final imageUrl = products.isNotEmpty
                      ? products.first.imageUrl
                      : '';

                  final tempProduct = Product(
                    id: '',
                    sku: '',
                    name: '',
                    description: '',
                    category: category,
                    subType: '',
                    price: 0,
                    imageUrl: imageUrl,
                    features: [],
                    stockQuantity: 0,
                    color: primaryColor,
                    colorName: '',
                  );

                  return _CategoryTile(
                    label: tempProduct.categoryDisplayName,
                    imageUrl: imageUrl,
                    isSelected:
                        selectedCategory == category && selectedSubType == null,
                    count: count,
                    onTap: () => onCategorySelected(category),
                  );
                }).toList(),
              ],
            ),
          ),

          // Support Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.contact_support_outlined,
                  color: primaryColor,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'Need Help?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                Column(
                  children: [
                    Text(
                      AppConstants.supportEmail,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      AppConstants.supportPhone,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _CategoryTile({
    Key? key,
    required this.label,
    this.imageUrl,
    required this.isSelected,
    required this.count,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Highlight background
            Positioned.fill(
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF3F1F6)
                      : Colors.transparent,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  // Circular image thumbnail
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 238, 238, 238),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? (imageUrl!.startsWith('http')
                              ? Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey.shade400,
                                        size: 36,
                                      ),
                                )
                              : Image.asset(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey.shade400,
                                        size: 36,
                                      ),
                                ))
                        : Icon(
                            Icons.category,
                            color: Colors.grey.shade400,
                            size: 36,
                          ),
                  ),
                  const SizedBox(width: 20),

                  // Label and item count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        if (!isSelected)
                          Text(
                            '$count items',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
