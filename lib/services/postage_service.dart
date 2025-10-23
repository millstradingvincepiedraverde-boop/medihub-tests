import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/postage_rate.dart';

class PostageService {
  static const String _baseUrl =
      'https://api.millsbrands.com.au/api/v1/postage-calculator';

  /// ✅ Fetch all postage rates from Mills Brands API
  Future<List<PostageRate>> fetchPostageRates({
    required String sku,
    required String zip,
    required int qty,
  }) async {
    final uri = Uri.parse('$_baseUrl?sku=$sku&zip=$zip&qty=$qty&services=all');
    print('🌐 [PostageService] Fetching postage rates from: $uri');

    try {
      final response = await http.get(uri);
      print('📦 [PostageService] Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print(
          '❌ [PostageService] Failed to fetch rates. Body: ${response.body}',
        );
        throw Exception('Failed to fetch postage rates');
      }

      final body = jsonDecode(response.body);
      print('✅ [PostageService] Response parsed successfully.');

      final onDemand = body['onDemand'] as List? ?? [];
      final postage =
          double.tryParse(body['postage']?.toString() ?? '0') ?? 0.0;

      print('📊 [PostageService] Found ${onDemand.length} on-demand rate(s)');

      final rates = onDemand.map((rate) {
        return PostageRate.fromJson(rate, sku: sku);
      }).toList();

      // If no on-demand rates exist, return a basic postage rate
      if (rates.isEmpty) {
        rates.add(
          PostageRate(
            service: 'Standard Delivery',
            cost: postage,
            sku: sku,
            eta: 'N/A',
            code: '',
          ),
        );
      }

      return rates;
    } catch (e) {
      print('🚨 [PostageService] Error: $e');
      rethrow;
    }
  }

  /// ✅ Compute Shopify-like rates (same logic as calculateShipping)
  Future<Map<String, dynamic>> calculateShipping(
    Map<String, dynamic> body,
  ) async {
    print("🚚 [PostageService] Calculate Shipping Called");

    final destination = body['rate']?['destination'] ?? {};
    final items = List<Map<String, dynamic>>.from(body['rate']?['items'] ?? []);
    final postalCode = destination['postal_code']?.toString() ?? '';

    double totalShippingCost = 0;
    final Map<String, Map<String, dynamic>> onDemandTotals = {};
    bool allItemsHaveOnDemand = true;

    int toCents(num n) => (n * 100).round();

    for (final item in items) {
      final sku = item['sku']?.toString() ?? '';
      final quantity = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;

      try {
        final rates = await fetchPostageRates(
          sku: sku,
          zip: postalCode,
          qty: quantity,
        );

        // Standard postage
        final base = rates.isNotEmpty ? rates.first.cost : 0;
        totalShippingCost += base;

        // On-demand aggregation
        if (rates.isEmpty || rates.first.service == 'Standard Delivery') {
          allItemsHaveOnDemand = false;
        } else {
          for (final rate in rates) {
            final label = rate.service.trim();
            final internal = label.toLowerCase().replaceAll(' ', '_');
            if (onDemandTotals.containsKey(internal)) {
              onDemandTotals[internal]!['total'] += rate.cost;
            } else {
              onDemandTotals[internal] = {'label': label, 'total': rate.cost};
            }
          }
        }
      } catch (e) {
        print("⚠️ [PostageService] Error fetching shipping for $sku: $e");
        allItemsHaveOnDemand = false;
        continue;
      }
    }

    final List<Map<String, dynamic>> ratesResult = [];

    if (allItemsHaveOnDemand && onDemandTotals.isNotEmpty) {
      // ✅ All items have on-demand → show free on-demand options
      for (final entry in onDemandTotals.entries) {
        ratesResult.add({
          'service_name': entry.value['label'],
          'service_code': entry.key,
          'total_price': 0,
          'currency': 'AUD',
        });
      }
    } else {
      // ❌ Some items lack on-demand → show standard delivery
      ratesResult.add({
        'service_name': 'Standard Delivery',
        'service_code': 'mills_shipping',
        'total_price': toCents(totalShippingCost),
        'currency': 'AUD',
      });
    }

    return {'rates': ratesResult};
  }

  /// ✅ Simplified function to get cheapest postage cost
  Future<double> getPostageCost({
    required String sku,
    required String zip,
    required int qty,
  }) async {
    print(
      '🔍 [PostageService] Getting postage cost for SKU: $sku ZIP: $zip QTY: $qty',
    );

    try {
      final rates = await fetchPostageRates(sku: sku, zip: zip, qty: qty);

      if (rates.isEmpty) {
        print('⚠️ [PostageService] No postage rates found — defaulting to 0.0');
        return 0.0;
      }

      rates.sort((a, b) => a.cost.compareTo(b.cost));
      final lowest = rates.first;

      print(
        '💰 [PostageService] Selected cheapest rate: ${lowest.service} — \$${lowest.cost}',
      );
      return lowest.cost;
    } catch (e) {
      print('🚨 [PostageService] Error getting postage cost: $e');
      return 0.0;
    }
  }
}
