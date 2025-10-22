import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// ENUMS (Aligned with Sanity Categories)
/// ------------------------------------------------------------
enum ProductCategory {
  rollators,
  kneeScooters,
  recliners,
  bathroom,
  bedroom,
  patientLifts,
  ramps,
  manualWheelchairs,
  electricWheelchairs,
  wheelchairs,
  scooters,
  unknown,
}

/// ------------------------------------------------------------
/// CATEGORY HELPER
/// ------------------------------------------------------------
class ProductCategoryHelper {
  static ProductCategory fromString(String? value) {
    final v = (value ?? '').trim().toLowerCase().replaceAll(' ', '');

    switch (v) {
      case 'rollators':
        return ProductCategory.rollators;
      case 'kneescooters':
        return ProductCategory.kneeScooters;
      case 'recliners':
        return ProductCategory.recliners;
      case 'bathroom':
        return ProductCategory.bathroom;
      case 'bedroom':
        return ProductCategory.bedroom;
      case 'patientlifts':
        return ProductCategory.patientLifts;
      case 'ramps':
        return ProductCategory.ramps;
      case 'manualwheelchairs':
        return ProductCategory.manualWheelchairs;
      case 'electricwheelchairs':
        return ProductCategory.electricWheelchairs;
      case 'wheelchairs':
        return ProductCategory.wheelchairs;
      case 'scooters':
        return ProductCategory.scooters;

      // Handle unexpected values like "New Top Level"
      default:
        debugPrint('⚠️ Unknown category: "$value" → defaulting to Wheelchairs');
        return ProductCategory.wheelchairs;
    }
  }

  static String toStringValue(ProductCategory category) {
    switch (category) {
      case ProductCategory.rollators:
        return 'Rollators';
      case ProductCategory.kneeScooters:
        return 'Knee Scooters';
      case ProductCategory.recliners:
        return 'Recliners';
      case ProductCategory.bathroom:
        return 'Bathroom';
      case ProductCategory.bedroom:
        return 'Bedroom';
      case ProductCategory.patientLifts:
        return 'Patient Lifts';
      case ProductCategory.ramps:
        return 'Ramps';
      case ProductCategory.manualWheelchairs:
        return 'Manual Wheelchairs';
      case ProductCategory.electricWheelchairs:
        return 'Electric Wheelchairs';
      case ProductCategory.wheelchairs:
        return 'Wheelchairs';
      case ProductCategory.scooters:
        return 'Scooters';
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

  /// ------------------------------------------------------------
  /// EMPTY FACTORY
  /// ------------------------------------------------------------
  factory Product.empty() => Product(
    id: '',
    sku: '',
    name: '',
    description: '',
    price: 0,
    category: ProductCategory.unknown,
    imageUrl: '',
  );

  /// Extracts readable text from Sanity's Portable Text or raw JSON description.
  static String _extractDescription(dynamic value) {
    if (value == null) return '';

    // If it's already a simple string
    if (value is String) return value;

    // If it's a Sanity block array
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

    // If it's a single block map
    if (value is Map && value['children'] is List) {
      return value['children']
          .map((child) => child['text'] ?? '')
          .join('\n')
          .toString()
          .trim();
    }

    // Default fallback
    return value.toString();
  }

  /// ------------------------------------------------------------
  /// FROM SANITY (SAFE PARSING)
  /// --------------------------
  ///
  ///
  /// ----------------------------------
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

    // ✅ Category handling (handles reference)
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

  /// ------------------------------------------------------------
  /// TO JSON
  /// ------------------------------------------------------------
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

  /// ------------------------------------------------------------
  /// DISPLAY HELPERS
  /// ------------------------------------------------------------
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
      case ProductCategory.rollators:
        return Icons.wheelchair_pickup_rounded;
      case ProductCategory.kneeScooters:
        return Icons.two_wheeler_rounded;
      case ProductCategory.recliners:
        return Icons.chair_alt_rounded;
      case ProductCategory.bathroom:
        return Icons.bathtub_rounded;
      case ProductCategory.bedroom:
        return Icons.bed_rounded;
      case ProductCategory.patientLifts:
        return Icons.accessibility_new_rounded;
      case ProductCategory.ramps:
        return Icons.stairs_rounded;
      case ProductCategory.manualWheelchairs:
        return Icons.accessible_forward_rounded;
      case ProductCategory.electricWheelchairs:
        return Icons.electric_bike_rounded;
      case ProductCategory.wheelchairs:
        return Icons.wheelchair_pickup_rounded;
      case ProductCategory.scooters:
        return Icons.electric_scooter_rounded;
      case ProductCategory.unknown:
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
