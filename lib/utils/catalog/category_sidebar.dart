import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:medihub_tests/controllers/product_controller.dart';
import 'package:medihub_tests/models/product.dart';
import 'package:medihub_tests/constants/app_constants.dart';
import 'package:medihub_tests/services/push_token_simple.dart';

class CategorySidebar extends StatefulWidget {
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
  State<CategorySidebar> createState() => _CategorySidebarState();
}

class _CategorySidebarState extends State<CategorySidebar> {
  int _tapCount = 0;
  DateTime? _firstTapTime;
  static const _tapWindowDuration = Duration(seconds: 2);
  static const _requiredTaps = 5;

  void _handleLogoTap() {
    final now = DateTime.now();

    // Reset if too much time has passed since first tap
    if (_firstTapTime != null &&
        now.difference(_firstTapTime!) > _tapWindowDuration) {
      _tapCount = 1;
      _firstTapTime = now;
      return;
    }

    // Initialize first tap time
    if (_firstTapTime == null) {
      _firstTapTime = now;
      _tapCount = 1;
      return;
    }

    // Increment tap count
    _tapCount++;

    // Check if we've reached the required number of taps
    if (_tapCount >= _requiredTaps) {
      _showDeviceIdDialog();
      _tapCount = 0;
      _firstTapTime = null;
    }
  }

  Future<void> _showDeviceIdDialog() async {
    try {
      final deviceId = await PushTokenSimple.instance.getDeviceId();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Device ID'),
            content: SelectableText(
              deviceId,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('❌ Error getting device ID: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting device ID: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF4A306D);

    return Container(
      width: 320,
      color: Colors.white,
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === LOGO HEADER ===
          GestureDetector(
            onTap: () {
              debugPrint('🏠 MediHub logo tapped → returning to home screen');
              widget.onCategorySelected(null); // Reset category selection
              _handleLogoTap(); // Handle tap counting for device ID dialog
            },
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(color: Colors.white),
              child: SvgPicture.asset(
                'assets/images/medihub-logo.svg',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // === CATEGORY LIST ===
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
                        widget.selectedCategory == category && widget.selectedSubType == null,
                    count: count,
                    onTap: () {
                      debugPrint(
                        '🖱️ Category tapped: ${tempProduct.categoryDisplayName}',
                      );
                      widget.onCategorySelected(category);
                    },
                  );
                }).toList(),
              ],
            ),
          ),

          // === SUPPORT SECTION ===
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
      // 👇 remove right padding if selected to let it “connect”
      padding: EdgeInsets.only(
        left: 20,
        top: 10,
        bottom: 10,
        right: isSelected ? 0 : 20,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          clipBehavior: Clip.none, // 👈 allow overflow beyond container
          children: [
            // === Background highlight ===
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              // 👇 extend the right edge slightly beyond sidebar
              right: isSelected ? -10 : 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.grey.shade100
                      : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: const Radius.circular(16),
                    right: isSelected
                        ? const Radius.circular(0) // flatten edge
                        : const Radius.circular(16),
                  ),
                ),
              ),
            ),

            // === Content ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  // Thumbnail circle
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

                  // Label + count
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
