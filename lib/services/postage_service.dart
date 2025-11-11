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
  final uri = Uri.parse(
    'https://api.millsbrands.com.au/api/v1/postage-calculator'
    '?sku=$sku&zip=$zip&qty=$qty&services=all',
  );

  print('🌐 [PostageService] Fetching postage rates from: $uri');

  try {
    final response = await http.get(uri);
    print('📦 [PostageService] Response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      print('❌ [PostageService] Failed to fetch rates: ${response.body}');
      throw Exception('Failed to fetch postage rates');
    }

    final data = jsonDecode(response.body);
    print('✅ [PostageService] Parsed successfully: $data');

    final List<PostageRate> rates = [];

    // 🎯 Check On Demand first
    if (data['onDemand'] != null && data['onDemand'] is List) {
      for (final option in data['onDemand']) {
        rates.add(PostageRate(
          service: option['label'] ?? 'Delivered Today -',
          eta: option['label'] ?? '',
          cost: double.tryParse(option['cost']?.toString() ?? '0') ?? 0,
          code: 'ON_DEMAND',
          sku: sku,
        ));
      }
    }

    // 📦 Add standard postage fallback
    final postageCost =
        double.tryParse(data['postage']?.toString() ?? '0') ?? 0.0;

    if (rates.isEmpty || postageCost > 0) {
      rates.add(PostageRate(
        service: 'Standard Delivery',
        eta: '2–5 Business Days',
        cost: postageCost,
        code: 'STANDARD',
        sku: sku,
      ));
    }

    return rates;
  } catch (e) {
    print('🚨 [PostageService] Error: $e');
    rethrow;
  }
}


  /// ✅ Compute Shopify-like rates (decides if FREE on-demand or standard)
  Future<Map<String, dynamic>> calculateShipping(
    Map<String, dynamic> body,
  ) async {
    print("🚚 [PostageService] Calculate Shipping Called");

    final destination = body['rate']?['destination'] ?? {};
    final items = List<Map<String, dynamic>>.from(body['rate']?['items'] ?? []);
    final postalCode = destination['postal_code']?.toString() ?? '';

    double totalShippingCost = 0;
    bool allHaveOnDemand = true;

    for (final item in items) {
      final sku = item['sku']?.toString() ?? '';
      final quantity = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;

      try {
        final rates = await fetchPostageRates(
          sku: sku,
          zip: postalCode,
          qty: quantity,
        );

        // If product has no On Demand, mark false and use postage rate
        if (rates.any((r) => r.service.toLowerCase().contains('on demand'))) {
          print("🟢 [PostageService] $sku supports On Demand");
        } else {
          print("🟠 [PostageService] $sku uses standard delivery");
          allHaveOnDemand = false;
          final postageRate = rates.first.cost;
          totalShippingCost += postageRate;
        }
      } catch (e) {
        print("⚠️ [PostageService] Error fetching rates for $sku: $e");
        allHaveOnDemand = false;
      }
    }

    final List<Map<String, dynamic>> ratesResult = [];

    if (allHaveOnDemand) {
      // ✅ Show one combined FREE On Demand option
      ratesResult.add({
        'service_name': 'On Demand Delivery',
        'service_code': 'FREE_ON_DEMAND',
        'total_price': 0,
        'currency': 'AUD',
      });
      print("🎉 [PostageService] All items have On Demand → Free delivery!");
    } else {
      // 🚚 Otherwise, show standard delivery with summed cost
      final int totalCents = (totalShippingCost * 100).round();
      ratesResult.add({
        'service_name': 'Standard Delivery',
        'service_code': 'mills_shipping',
        'total_price': totalCents,
        'currency': 'AUD',
      });
      print(
        "📦 [PostageService] Standard delivery total: \$${totalShippingCost.toStringAsFixed(2)}",
      );
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
