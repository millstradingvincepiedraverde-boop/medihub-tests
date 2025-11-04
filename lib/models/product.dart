import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// ENUMS (Aligned with Sanity Categories)
/// ------------------------------------------------------------
enum ProductCategory {
  mobilityScooters,
  rollators,
  ramps,
  bathroom,
  recliners,
  patientLifts,
  kneeScooters,
  bedroom,
  unknown,
}

/// ------------------------------------------------------------
/// CATEGORY HELPER
/// ------------------------------------------------------------
class ProductCategoryHelper {
  static ProductCategory fromString(String? value) {
    final v = (value ?? '').trim().toLowerCase().replaceAll(' ', '');

    switch (v) {
      case 'mobilityscooters':
      case 'scooters':
        return ProductCategory.mobilityScooters;
      case 'rollators':
        return ProductCategory.rollators;

      case 'ramps':
        return ProductCategory.ramps;
      case 'bathroom':
        return ProductCategory.bathroom;
      case 'recliners':
        return ProductCategory.recliners;
      case 'patientlifts':
        return ProductCategory.patientLifts;
      case 'kneescooters':
        return ProductCategory.kneeScooters;

      case 'bedroom':
        return ProductCategory.bedroom;

      default:
        debugPrint('⚠️ Unknown category: "$value" → defaulting to Unknown');
        return ProductCategory.unknown;
    }
  }

  static String toStringValue(ProductCategory category) {
    switch (category) {
      case ProductCategory.mobilityScooters:
        return 'Mobility Scooters';
      case ProductCategory.rollators:
        return 'Rollators';

      case ProductCategory.ramps:
        return 'Ramps';
      case ProductCategory.bathroom:
        return 'Bathroom';
      case ProductCategory.recliners:
        return 'Recliners';
      case ProductCategory.patientLifts:
        return 'Patient Lifts';
      case ProductCategory.kneeScooters:
        return 'Knee Scooters';

      case ProductCategory.bedroom:
        return 'Bedroom';
      case ProductCategory.unknown:
        return 'Unknown';
    }
  }
}

/// ------------------------------------------------------------
/// PRODUCT MODEL
/// ------------------------------------------------------------
class Product {
  final String id;
  final String sku;
  final String name;
  final String description;
  final double price;
  final ProductCategory category;
  final String subType;
  final String imageUrl;
  final List<String> features;
  final int stockQuantity;
  final Color? color;
  final String colorName;
  final List<String> alternativeProductIds;
  final List<String> upgradeProductIds;
  final bool hasSameDayDelivery;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.subType = '',
    required this.imageUrl,
    this.features = const [],
    this.stockQuantity = 0,
    this.color,
    this.colorName = '',
    this.alternativeProductIds = const [],
    this.upgradeProductIds = const [],
    this.hasSameDayDelivery = false,
  });

  factory Product.empty() => Product(
    id: '',
    sku: '',
    name: '',
    description: '',
    price: 0,
    category: ProductCategory.unknown,
    imageUrl: '',
  );

  static String _extractDescription(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) {
      final buffer = StringBuffer();
      for (var block in value) {
        if (block is Map && block['children'] is List) {
          for (var child in block['children']) {
            if (child is Map && child['text'] is String) {
              buffer.writeln(child['text']);
            }
          }
        }
      }
      return buffer.toString().trim();
    }
    if (value is Map && value['children'] is List) {
      return value['children']
          .map((child) => child['text'] ?? '')
          .join('\n')
          .toString()
          .trim();
    }
    return value.toString();
  }

  factory Product.fromSanity(Map<String, dynamic> json) {
    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value is Map && value['title'] != null)
        return value['title'].toString();
      return value.toString();
    }

    double safeDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    // ✅ Handle image (CDN URL or asset ref)
    String imageUrl = '';
    final imageData = json['image'];
    if (imageData is Map && imageData['asset'] != null) {
      final asset = imageData['asset'];
      if (asset is Map && asset['url'] is String) {
        imageUrl = asset['url'];
      } else if (asset is Map && asset['_ref'] is String) {
        final ref = asset['_ref'];
        final parts = ref.split('-');
        if (parts.length >= 3) {
          imageUrl =
              'https://cdn.sanity.io/images/je8kjwqv/production/${parts[1]}-${parts[2]}.jpg';
        }
      }
    } else if (json['imageUrl'] is String) {
      imageUrl = json['imageUrl'];
    }

    // ✅ Category handling
    String rawCategory = '';
    final categoryData = json['category'] ?? json['topLevelCategory'];
    if (categoryData is Map && categoryData['title'] != null) {
      rawCategory = categoryData['title'];
    } else {
      rawCategory = safeString(categoryData);
    }

    return Product(
      id: safeString(json['_id']),
      sku: safeString(json['sku']),
      name: safeString(json['title'] ?? json['name']),
      description: _extractDescription(json['description']),
      price: safeDouble(json['listPrice'] ?? json['price']),
      category: ProductCategoryHelper.fromString(rawCategory),
      subType: safeString(json['subCategory'] ?? json['subType']),
      imageUrl: imageUrl,
      features: (json['features'] is List)
          ? List<String>.from(json['features'].map((f) => safeString(f)))
          : [],
      stockQuantity: safeInt(json['quantity'] ?? json['stockQuantity']),
      colorName: safeString(json['colorName']),
      hasSameDayDelivery: json['hasSameDayDelivery'] == true,
      alternativeProductIds: (json['alternativeProductIds'] is List)
          ? List<String>.from(
              json['alternativeProductIds'].map((id) => safeString(id)),
            )
          : [],
      upgradeProductIds: (json['upgradeProductIds'] is List)
          ? List<String>.from(
              json['upgradeProductIds'].map((id) => safeString(id)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'price': price,
      'category': ProductCategoryHelper.toStringValue(category),
      'subType': subType,
      'imageUrl': imageUrl,
      'features': features,
      'stockQuantity': stockQuantity,
      'colorName': colorName,
      'hasSameDayDelivery': hasSameDayDelivery,
      'alternativeProductIds': alternativeProductIds,
      'upgradeProductIds': upgradeProductIds,
    };
  }

  String get categoryDisplayName =>
      ProductCategoryHelper.toStringValue(category);

  String get subTypeDisplayName {
    final subTypeStr = subType.toLowerCase();
    if (subTypeStr.contains('manual')) return 'Manual';
    if (subTypeStr.contains('electric')) return 'Electric';
    if (subTypeStr.contains('transport')) return 'Transport';
    if (subTypeStr.contains('travelscooter')) return 'Travel Scooter';
    if (subTypeStr.contains('heavyduty')) return 'Heavy Duty';
    if (subTypeStr.contains('foldable')) return 'Foldable';
    if (subTypeStr.contains('walkingaids')) return 'Walking Aids';
    if (subTypeStr.contains('bathroomsafety')) return 'Bathroom Safety';
    if (subTypeStr.contains('reachersgrabbers')) return 'Reachers & Grabbers';
    if (subTypeStr.contains('hospitalbeds')) return 'Hospital Beds';
    if (subTypeStr.contains('oxygenconcentrators'))
      return 'Oxygen Concentrators';
    if (subTypeStr.contains('bloodpressuremonitors'))
      return 'Blood Pressure Monitors';
    return 'All';
  }

  IconData get categoryIcon {
    switch (category) {
      case ProductCategory.mobilityScooters:
        return Icons.electric_scooter_rounded;
      case ProductCategory.rollators:
        return Icons.wheelchair_pickup_rounded;

      case ProductCategory.ramps:
        return Icons.stairs_rounded;
      case ProductCategory.bathroom:
        return Icons.bathtub_rounded;
      case ProductCategory.recliners:
        return Icons.chair_alt_rounded;
      case ProductCategory.patientLifts:
        return Icons.accessibility_new_rounded;
      case ProductCategory.kneeScooters:
        return Icons.two_wheeler_rounded;

      case ProductCategory.bedroom:
        return Icons.bed_rounded;
      case ProductCategory.unknown:
        return Icons.inventory_2_outlined;
    }
  }
}
