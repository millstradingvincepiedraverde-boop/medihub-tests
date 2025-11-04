import 'package:flutter/material.dart';
import 'package:medihub_tests/models/product.dart';
import 'package:medihub_tests/services/category_service.dart';
import 'package:shimmer/shimmer.dart';

class TopCategoriesSection extends StatefulWidget {
  final Function(ProductCategory)? onCategoryTap;

  const TopCategoriesSection({Key? key, this.onCategoryTap}) : super(key: key);

  @override
  State<TopCategoriesSection> createState() => _TopCategoriesSectionState();
}

class _TopCategoriesSectionState extends State<TopCategoriesSection> {
  final CategoryService _categoryService = CategoryService();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _error;

  final Map<String, ProductCategory> _categoryMap = {
    'Mobility Scooters': ProductCategory.mobilityScooters,
    'Rollators': ProductCategory.rollators,
    'Ramps': ProductCategory.ramps,
    'Bathroom': ProductCategory.bathroom,
    'Recliners': ProductCategory.recliners,
    'Patient Lifts': ProductCategory.patientLifts,
    'Knee Scooters': ProductCategory.kneeScooters,
    'Bedroom': ProductCategory.bedroom,
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.fetchCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
      print('🟢 Categories loaded successfully (${categories.length})');
    } catch (e) {
      print('🔴 Failed to load categories: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildSkeletonLoader(context);
    if (_error != null) return Center(child: Text('Error loading: $_error'));

    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Categories',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.9, // ✅ Smaller, fits 2 cards nicely
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final title = category['title'] ?? 'Unnamed';
                  final imageUrl = category['imageUrl'] ?? '';
                  final ProductCategory mappedCategory =
                      _categoryMap[title] ?? ProductCategory.unknown;

                  return _CategoryCard(
                    title: title,
                    description:
                        category['description'] ??
                        'We offer a wide range of styles and sizes.',
                    imageUrl: imageUrl,
                    onTap: () {
                      print('🟢 Tapped: $title → $mappedCategory');
                      widget.onCategoryTap?.call(mappedCategory);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🦴 Skeleton loader
  Widget _buildSkeletonLoader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 32,
              width: 200,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 28),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.9,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(20),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ✅ Compact, elegant card
class _CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // 🖼️ Product image (bottom-right)
              Positioned(
                bottom: 0,
                right: 0,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        height: 180, // ✅ smaller
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      )
                    : const SizedBox(),
              ),

              // 📝 Text overlay
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 180,
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
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
  }
}
