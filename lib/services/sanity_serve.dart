import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class SanityService {
  static const String projectId = 'je8kjwqv';
  static const String dataset = 'production';
  static const String apiVersion = '2023-05-03';

  static String get baseUrl =>
      'https://$projectId.api.sanity.io/v$apiVersion/data/query/$dataset';

  static Future<List<Product>> fetchProducts() async {
    const query = '*[_type == "product"]{_id, name, sku, description, price, category, subType, "imageUrl": imageUrl.asset->url, features, stockQuantity, colorName, hasSameDayDelivery}';
    final url = Uri.parse('$baseUrl?query=$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['result'] as List<dynamic>;
      return results.map((json) => Product.fromSanity(json)).toList();
    } else {
      throw Exception('Failed to fetch products from Sanity');
    }
  }
}
