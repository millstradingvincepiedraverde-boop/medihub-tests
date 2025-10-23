// lib/models/postage_rate.dart
class PostageRate {
  final String service; // e.g. "Standard", "Express"
  final double cost; // numeric cost
  final String eta; // human-friendly ETA e.g. "1-2 business days"
  final String code; // optional service code from API
  final String sku; // SKU this rate belongs to

  PostageRate({
    required this.service,
    required this.cost,
    required this.eta,
    required this.code,
    required this.sku,
  });

  factory PostageRate.fromJson(
    Map<String, dynamic> json, {
    required String sku,
  }) {
    // Defensive parsing to handle missing or differently named fields
    final service =
        (json['service'] ?? json['name'] ?? json['label'])?.toString() ??
        'Unknown';
    final costVal = json['cost'] ?? json['price'] ?? json['amount'] ?? 0;
    final cost = (costVal is String)
        ? double.tryParse(costVal) ?? 0.0
        : (costVal is num ? costVal.toDouble() : 0.0);
    final eta =
        (json['eta'] ?? json['estimated_delivery'] ?? '')?.toString() ?? '';
    final code = (json['code'] ?? json['service_code'] ?? '')?.toString() ?? '';

    return PostageRate(
      service: service,
      cost: cost,
      eta: eta,
      code: code,
      sku: sku,
    );
  }

  Map<String, dynamic> toJson() => {
    'service': service,
    'cost': cost,
    'eta': eta,
    'code': code,
    'sku': sku,
  };
}
