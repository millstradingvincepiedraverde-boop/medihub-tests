import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;
  final bool showSubcategoryFilter;
  final String? selectedSubTypeDisplay;
  final VoidCallback? onFilterPressed;

  const SearchFilterBar({
    Key? key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    this.showSubcategoryFilter = false,
    this.selectedSubTypeDisplay,
    this.onFilterPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: TextField(
              controller: searchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products by name or description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: onClearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey.shade100,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),

          const SizedBox(width: 16),

          // Subcategory Filter Button
          if (showSubcategoryFilter)
            TextButton.icon(
              icon: const Icon(Icons.filter_list),
              label: Text(
                selectedSubTypeDisplay ?? 'All Types',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A306D),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4A306D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onFilterPressed,
            ),
        ],
      ),
    );
  }
}