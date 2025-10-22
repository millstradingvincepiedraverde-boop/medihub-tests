import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  // 🧠 Sanity project configuration
  static const String projectId = 'je8kjwqv';
  static const String dataset = 'production';
  static const String apiVersion = '2025-01-01'; // or your preferred date

  // ✅ Enhanced GROQ query — fully dereferenced and aligned with Product.fromSanity
  static const String query = r'''
*[_type == "product"]{
  _id,
  title,
  sku,
  description,
  listPrice,
  quantity,
  colorName,
  hasSameDayDelivery,
  features[],
  alternativeProductIds[],
  upgradeProductIds[],

  // ✅ Dereference category and subcategory titles
  "category": category->{ title },
  "subCategory": subCategory->{ title },

  // ✅ Image URL direct from CDN
  "image": {
    "asset": {
      "url": image.asset->url
    }
  }
}
''';

  Future<List<Product>> fetchProducts() async {
    final url =
        'https://$projectId.apicdn.sanity.io/v$apiVersion/data/query/$dataset?query=${Uri.encodeComponent(query)}';

    print('🛰 Fetching products from Sanity: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch products. Status: ${response.statusCode}',
      );
    }

    final data = json.decode(response.body);

    final List productsJson = data['result'] ?? [];
    print('✅ Retrieved ${productsJson.length} products from Sanity');

    return productsJson.map((json) => Product.fromSanity(json)).toList();
  }
}
