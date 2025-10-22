import '../models/postage_rate.dart';
import '../services/postage_service.dart';

class PostageController {
  final PostageService _service = PostageService();

  Future<List<PostageRate>> getRates({
    required String sku,
    required String zip,
    required int qty,
  }) async {
    try {
      final rates = await _service.fetchPostageRates(
        sku: sku,
        zip: zip,
        qty: qty,
      );
      return rates;
    } catch (e) {
      print('Error in PostageController: $e');
      return [];
    }
  }

  Future<List<PostageRate>> fetchRates(String sku, String zip, int qty) async {
    // You can add caching or transformation logic here later
    final rates = await _service.fetchPostageRates(
      sku: sku,
      zip: zip,
      qty: qty,
    );
    // Sort cheapest first
    rates.sort((a, b) => a.cost.compareTo(b.cost));
    return rates;
  }

  /// Helper: get cheapest rate
  Future<PostageRate?> getCheapestRate({
    required String sku,
    required String zip,
    required int qty,
  }) async {
    final rates = await getRates(sku: sku, zip: zip, qty: qty);
    if (rates.isEmpty) return null;
    rates.sort((a, b) => a.cost.compareTo(b.cost));
    return rates.first;
  }
}
