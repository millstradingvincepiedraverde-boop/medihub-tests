// lib/services/postage_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/postage_rate.dart';

class PostageService {
  // Use the API base / full URL you provided
  // Example: https://api.millsbrands.com.au/api/v1/postage-calculator?sku=...&zip=...&qty=...&services=all
  final String _baseUrl =
      'https://api.millsbrands.com.au/api/v1/postage-calculator';

  Future<List<PostageRate>> fetchPostageRates({
    required String sku,
    required String zip,
    required int qty,
    String services = 'all',
    Map<String, String>? extraHeaders,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'sku': sku,
        'zip': zip,
        'qty': qty.toString(),
        'services': services,
      },
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      if (extraHeaders != null) ...extraHeaders,
    };

    final resp = await http.get(uri, headers: headers);

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch postage rates (${resp.statusCode})');
    }

    final Map<String, dynamic> body =
        json.decode(resp.body) as Map<String, dynamic>;

    // Try common response shapes:
    // 1) { "data": [ {...}, {...} ] }
    // 2) { "rates": [ {...} ] }
    // 3) direct list: [ {...}, {...} ]
    List<dynamic> list = [];

    if (body.containsKey('data') && body['data'] is List) {
      list = body['data'] as List<dynamic>;
    } else if (body.containsKey('rates') && body['rates'] is List) {
      list = body['rates'] as List<dynamic>;
    } else {
      // attempt to find the first list inside the response
      final candidate = body.values.firstWhere(
        (v) => v is List,
        orElse: () => null,
      );
      if (candidate is List) list = candidate;
    }

    // If still empty and root JSON is a list (some APIs), handle it
    if (list.isEmpty) {
      try {
        final decoded = json.decode(resp.body);
        if (decoded is List) list = decoded;
      } catch (_) {}
    }

    // Map to PostageRate defensively
    final rates = list.map<PostageRate>((item) {
      if (item is Map<String, dynamic>) {
        return PostageRate.fromJson(item);
      } else if (item is Map) {
        return PostageRate.fromJson(Map<String, dynamic>.from(item));
      } else {
        // fallback: create an "unknown" rate
        return PostageRate(
          service: item.toString(),
          cost: 0.0,
          eta: '',
          code: '',
        );
      }
    }).toList();

    return rates;
  }
}
