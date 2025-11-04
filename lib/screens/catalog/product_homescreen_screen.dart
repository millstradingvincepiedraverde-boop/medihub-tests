import 'package:flutter/material.dart';
import 'package:medihub_tests/utils/catalog/category_sidebar.dart';
import 'package:medihub_tests/utils/catalog/mobile_category_chips.dart';
import 'package:medihub_tests/widgets/homepage/most_popular_section.dart';
import 'package:medihub_tests/widgets/homepage/qr_code_banner.dart';
import 'package:medihub_tests/widgets/homepage/top_categories_section.dart';
import 'package:provider/provider.dart';
import 'package:medihub_tests/controllers/product_controller.dart';
import 'package:medihub_tests/models/product.dart';
import 'package:medihub_tests/services/order_service.dart';
import 'package:medihub_tests/widgets/footer_widget.dart';
import 'package:medihub_tests/widgets/bottom_cart_button.dart';

class ProductHomescreenScreen extends StatefulWidget {
  const ProductHomescreenScreen({super.key});

  @override
  State<ProductHomescreenScreen> createState() =>
      _ProductHomescreenScreenState();
}

class _ProductHomescreenScreenState extends State<ProductHomescreenScreen> {
  final OrderService _orderService = OrderService();
  static const double _kTabletBreakpoint = 800.0;

  ProductCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductController>().fetchProducts(forceRefresh: true);
    });
  }

  void _handleCategorySelected(ProductCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _handleProductTap(Product product) {}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= _kTabletBreakpoint;
    final productController = context.watch<ProductController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLargeScreen
          ? Row(
              children: [
                // Desktop/Tablet: Sidebar
                CategorySidebar(
                  selectedCategory: _selectedCategory,
                  selectedSubType: null,
                  onCategorySelected: _handleCategorySelected,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildMainContent(productController.products)),
              ],
            )
          : Column(
              children: [
                // Mobile: Category Chips
                MobileCategoryChips(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: _handleCategorySelected,
                ),
                Expanded(child: _buildMainContent(productController.products)),
              ],
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomCartButton(key: ValueKey(_orderService.cartItemCount)),
          const FooterWidget(),
        ],
      ),
    );
  }

  Widget _buildMainContent(List<Product> products) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MostPopularSection(
            products: products,
            onProductTap: _handleProductTap,
          ),
          TopCategoriesSection(onCategoryTap: _handleCategorySelected),
          const QRCodeBanner(),
        ],
      ),
    );
  }
}
