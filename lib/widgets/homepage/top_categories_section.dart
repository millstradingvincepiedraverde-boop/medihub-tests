import 'package:flutter/material.dart';
import 'package:medihub_tests/models/product.dart';
import 'package:medihub_tests/services/category_service.dart';
import 'package:shimmer/shimmer.dart'; // ✅ Add shimmer package

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

  /// ✅ Map category titles → ProductCategory
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
    if (_isLoading) {
      return _buildSkeletonLoader(context);
    }

    if (_error != null) {
      return Center(child: Text('Error loading categories: $_error'));
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Categories',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 2;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 1;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
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
                    description: category['description'] ??
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

  /// 🦴 Skeleton loader with shimmer effect
  Widget _buildSkeletonLoader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 36,
              width: 200,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 32),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 2;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 1;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: 4, // number of skeleton cards
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 24,
                                  width: 150,
                                  color: Colors.white,
                                  margin:
                                      const EdgeInsets.only(bottom: 12),
                                ),
                                Container(
                                  height: 16,
                                  width: 220,
                                  color: Colors.white,
                                  margin:
                                      const EdgeInsets.only(bottom: 8),
                                ),
                                Container(
                                  height: 16,
                                  width: 180,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -20,
                right: -10,
                child: SizedBox(
                  width: 280,
                  height: 240,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomRight,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported,
                                  color: Colors.grey[300], size: 60),
                        )
                      : Icon(Icons.image_not_supported,
                          color: Colors.grey[300], size: 60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
