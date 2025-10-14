import 'package:flutter/material.dart';

// --------------------------------------------------------------------------
// NEW: Top-level category grouping for all products
// --------------------------------------------------------------------------
enum EquipmentCategory {
  wheelchairs,
  mobilityScooters,
  dailyLivingAids,
  homeHealthCare,
}

// --------------------------------------------------------------------------
// Wheelchair-specific sub-types (re-used for filtering)
// --------------------------------------------------------------------------
enum WheelchairType {
  manual,
  electric,
  sport,
  pediatric,
  bariatric,
}

class Wheelchair {
  final String id;
  final String name;
  final String description;
  
  // 👇 CHANGED: Added category to link this model to the top group
  final EquipmentCategory category = EquipmentCategory.wheelchairs; 
  
  // 👇 EXISTING: Now acts as the sub-type/subcategory
  final WheelchairType type; 
  
  final double price;
  final String imageUrl;
  final List<String> features;
  final int stockQuantity;
  final double weight;
  final double maxUserWeight;
  final Color color;
  final String colorName;

  Wheelchair({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.imageUrl,
    required this.features,
    required this.stockQuantity,
    required this.weight,
    required this.maxUserWeight,
    required this.color,
    required this.colorName,
  });

  bool get isInStock => stockQuantity > 0;

  // Property to get the display name of the SUB-TYPE
// Inside the Wheelchair Model class

String get typeDisplayName {
  switch (type) {
    case WheelchairType.manual:
      return 'Manual Wheelchair'; // Added return
    case WheelchairType.electric:
      return 'Electric Wheelchair'; // Added return
    case WheelchairType.sport:
      return 'Sport Wheelchair'; // Added return
    case WheelchairType.pediatric:
      return 'Pediatric Wheelchair'; // Added return
    case WheelchairType.bariatric:
      return 'Bariatric Wheelchair'; // Added return
  }
  
  // NOTE: If you forget one case, Dart will require a final return/throw here
  // to ensure the function always returns a String.
  // throw Exception('Unknown WheelchairType: $type'); 
}

  // Property to get the display name of the MAIN CATEGORY
  String get categoryDisplayName {
    // Since Wheelchair is defined in this file, we know its category,
    // but the pattern is useful if you create a generic 'Equipment' class later.
    return 'Wheelchairs'; 
  }

  // Icon for the sub-type
  IconData get typeIcon {
    switch (type) {
      case WheelchairType.manual:
        return Icons.accessible;
      case WheelchairType.electric:
        return Icons.electric_scooter;
      case WheelchairType.sport:
        return Icons.sports_basketball; // Changed for clarity
      case WheelchairType.pediatric:
        return Icons.child_care;
      case WheelchairType.bariatric:
        return Icons.airline_seat_recline_extra;
    }
  }
}