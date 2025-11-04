import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart'; // optional if ProductCategory enum is here, else remove

class CategoryService {
  // 🧠 Sanity configuration
  static const String projectId = 'je8kjwqv';
  static const String dataset = 'production';
  static const String apiVersion = '2025-01-01';

  // ✅ GROQ query to fetch top-level categories with image
  static const String query = r'''
*[_type == "category" && !defined(parentCategory)]{
  _id,
  title,
  description,
  "imageUrl": image.asset->url
}
''';

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final url =
        'https://$projectId.apicdn.sanity.io/v$apiVersion/data/query/$dataset?query=${Uri.encodeComponent(query)}';

    print('🛰 Fetching categories from Sanity: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch categories. Status: ${response.statusCode}',
      );
    }

    final data = json.decode(response.body);

    final List categoriesJson = data['result'] ?? [];
    print('✅ Retrieved ${categoriesJson.length} categories from Sanity');

    return categoriesJson.cast<Map<String, dynamic>>();
  }
}
