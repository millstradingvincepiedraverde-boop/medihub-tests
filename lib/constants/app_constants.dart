import 'package:flutter/material.dart';
// Note: Assuming 'Product' has been updated implicitly to include 
// bool hasSameDayDelivery = false, as shown in the product entries below.
import '../models/product.dart'; 

class AppConstants {
  // Define new product IDs for suggestions
  static const String ID_ROLLATOR_WALKER = 'dla004'; // New Alternative
  static const String ID_WALKER_CADDY = 'dla005'; // New Upgrade/Accessory

  // Product catalog with all categories
  static final List<Product> productCatalog = [
    // WHEELCHAIRS
    Product(
      id: 'wc001',
      name: 'Standard Manual Wheelchair',
      description: 'Durable steel frame wheelchair ideal for everyday use. Features padded armrests and footrests for maximum comfort.',
      category: ProductCategory.wheelchairs,
      subType: WheelchairType.manual,
      price: 299.00,
      imageUrl: 'assets/images/wheelchairs/wheelchair-1.jpg',
      features: [
        'Steel frame construction',
        'Padded armrests and seat',
        'Swing-away footrests',
        'Desk-length armrests',
        '18" seat width',
      ],
      stockQuantity: 20,
      color: Colors.blue,
      colorName: 'Black',
      alternativeProductIds: const ['dla005'], 
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: true, 
    ),
    Product(
      id: 'wc002',
      name: 'Electric Power Wheelchair',
      description: 'Advanced motorized wheelchair with joystick control. Long-lasting battery for extended use.',
      category: ProductCategory.wheelchairs,
      subType: WheelchairType.electric,
      price: 1850.00,
      imageUrl: 'assets/images/wheelchairs/wheelchair-2.jpg',
      features: [
        'Joystick controller',
        '20km battery range',
        '360-degree turning radius',
        'USB charging port',
        'LED headlights',
      ],
      stockQuantity: 8,
      color: Colors.blue,
      colorName: 'Charcoal',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: false, // Default is false
    ),
    Product(
      id: 'wc003',
      name: 'Transport Chair',
      description: 'Companion-propelled transport wheelchair with smaller wheels. Ideal for attendant-assisted mobility.',
      category: ProductCategory.wheelchairs,
      subType: WheelchairType.transport,
      price: 199.00,
      imageUrl: 'assets/images/wheelchairs/wheelchair-3.jpg',
      features: [
        'Lightweight design (9kg)',
        'Companion hand brakes',
        'Fold-down back',
        'Carry handles',
      ],
      stockQuantity: 25,
      color: Colors.blue,
      colorName: 'Blue',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: true,
    ),

    // MOBILITY SCOOTERS
    Product(
      id: 'ms001',
      name: 'Compact Travel Scooter',
      description: 'Lightweight and portable mobility scooter perfect for travel and shopping.',
      category: ProductCategory.mobilityScooters,
      subType: MobilityScooterType.travelScooter,
      price: 1299.00,
      imageUrl: 'assets/images/mobilityscooters/scooters-1.jpg',
      features: [
        'Disassembles into 5 pieces',
        '15km range per charge',
        'Fits in car trunk',
        'LED headlight',
        'Storage basket included',
      ],
      stockQuantity: 12,
      color: Colors.green,
      colorName: 'Red',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: false,
    ),
    Product(
      id: 'ms002',
      name: 'Heavy Duty 4-Wheel Scooter',
      description: 'Robust mobility scooter with enhanced weight capacity and all-terrain capability.',
      category: ProductCategory.mobilityScooters,
      subType: MobilityScooterType.heavyDuty,
      price: 2499.00,
      imageUrl: 'https://via.placeholder.com/300x300/5856D6/FFFFFF?text=Heavy+Duty',
      features: [
        'Up to 180kg weight capacity',
        '40km range',
        'Pneumatic tires',
        'Captain seat with armrests',
        'Digital dashboard',
      ],
      stockQuantity: 6,
      color: Colors.green,
      colorName: 'Black',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: false,
    ),
    Product(
      id: 'ms003',
      name: 'Foldable Mobility Scooter',
      description: 'Ultra-compact folding scooter with automatic folding mechanism.',
      category: ProductCategory.mobilityScooters,
      subType: MobilityScooterType.foldable,
      price: 1799.00,
      imageUrl: 'https://via.placeholder.com/300x300/00C7BE/FFFFFF?text=Foldable',
      features: [
        'One-button auto-fold',
        '12kg lightweight',
        'Airline approved',
        'LED lights front & rear',
      ],
      stockQuantity: 10,
      color: Colors.green,
      colorName: 'Silver',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: false,
    ),

    // DAILY LIVING AIDS
    Product(
      id: 'dla001',
      name: 'Folding Walker with Wheels',
      description: 'Adjustable height walker with front wheels for easy maneuverability.',
      category: ProductCategory.dailyLivingAids,
      subType: DailyLivingAidType.walkingAids,
      price: 89.00,
      imageUrl: 'https://via.placeholder.com/300x300/FF2D55/FFFFFF?text=Walker',
      features: [
        'Height adjustable',
        'Folds for storage',
        '5-inch front wheels',
        'Rear glide feet',
        'Tool-free assembly',
      ],
      stockQuantity: 30,
      color: Colors.pink,
      colorName: 'Silver',
      alternativeProductIds: [ID_ROLLATOR_WALKER], 
      upgradeProductIds: [ID_WALKER_CADDY], 
      // 💡 NEW TAG
      hasSameDayDelivery: true,
    ),
    Product(
      id: 'dla002',
      name: 'Shower Chair with Back',
      description: 'Durable shower chair with non-slip rubber tips for bathroom safety.',
      category: ProductCategory.dailyLivingAids,
      subType: DailyLivingAidType.bathroomSafety,
      price: 65.00,
      imageUrl: 'https://via.placeholder.com/300x300/AF52DE/FFFFFF?text=Shower+Chair',
      features: [
        'Height adjustable legs',
        'Padded seat and back',
        'Drainage holes',
        'Rust-resistant aluminum',
        'Tool-free assembly',
      ],
      stockQuantity: 25,
      color: Colors.pink,
      colorName: 'White',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: false,
    ),
    Product(
      id: 'dla003',
      name: 'Reacher Grabber Tool 32"',
      description: 'Long reach grabber tool with ergonomic handle and rotating head.',
      category: ProductCategory.dailyLivingAids,
      subType: DailyLivingAidType.reachersGrabbers,
      price: 24.99,
      imageUrl: 'https://via.placeholder.com/300x300/007AFF/FFFFFF?text=Reacher',
      features: [
        '32-inch reach',
        'Rotating jaw',
        'Magnetic tip',
        'Lightweight design',
        'Ergonomic trigger',
      ],
      stockQuantity: 50,
      color: Colors.pink,
      colorName: 'Blue',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: true,
    ),

    // NEW: Alternative Product for dla001 (Rollator Walker)
    Product(
      id: ID_ROLLATOR_WALKER,
      name: '4-Wheel Rollator with Seat',
      description: 'Premium rollator with four wheels, hand brakes, a seat, and under-seat storage.',
      category: ProductCategory.dailyLivingAids,
      subType: DailyLivingAidType.walkingAids,
      price: 139.00,
      imageUrl: 'https://via.placeholder.com/300x300/FFA500/FFFFFF?text=Rollator',
      features: [
        'Smooth-rolling 6-inch wheels',
        'Loop-lock hand brakes',
        'Padded seat and backrest',
        'Folding design',
        'Storage basket',
      ],
      stockQuantity: 15,
      color: Colors.pink,
      colorName: 'Red',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: false,
    ),

    // NEW: Upgrade Product for dla001 (Walker Caddy)
    Product(
      id: ID_WALKER_CADDY,
      name: 'Walker Storage Caddy',
      description: 'Convenient clip-on storage bag for walkers, includes cup holder.',
      category: ProductCategory.dailyLivingAids,
      subType: DailyLivingAidType.reachersGrabbers,
      price: 29.99,
      imageUrl: 'https://via.placeholder.com/300x300/32CD32/FFFFFF?text=Caddy',
      features: [
        'Universal fit',
        'Two mesh pockets',
        'Integrated cup holder',
        'Durable nylon material',
      ],
      stockQuantity: 50,
      color: Colors.pink,
      colorName: 'Black',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: true,
    ),

    // HOME HEALTH CARE
    Product(
      id: 'hhc001',
      name: 'Semi-Electric Hospital Bed',
      description: 'Adjustable hospital bed with electric head and foot sections.',
      category: ProductCategory.homeHealthCare,
      subType: HomeHealthCareType.hospital_beds,
      price: 1899.00,
      imageUrl: 'https://via.placeholder.com/300x300/8E8E93/FFFFFF?text=Hospital+Bed',
      features: [
        'Electric head & foot adjustment',
        'Side rails included',
        'Tool-free assembly',
        'Weight capacity 200kg',
        'Quiet motors',
      ],
      stockQuantity: 5,
      color: Colors.grey,
      colorName: 'Beige',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: false,
    ),
    Product(
      id: 'hhc002',
      name: 'Portable Oxygen Concentrator',
      description: 'Lightweight portable oxygen concentrator for home and travel use.',
      category: ProductCategory.homeHealthCare,
      subType: HomeHealthCareType.oxygenConcentrators,
      price: 2299.00,
      imageUrl: 'https://via.placeholder.com/300x300/34C759/FFFFFF?text=Oxygen',
      features: [
        'Pulse dose delivery',
        'Up to 5 liters per minute',
        'Battery powered',
        'Carry bag included',
        'FAA approved',
      ],
      stockQuantity: 8,
      color: Colors.grey,
      colorName: 'White',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: false,
    ),
    Product(
      id: 'hhc003',
      name: 'Digital Blood Pressure Monitor',
      description: 'Automatic blood pressure monitor with large LCD display and memory function.',
      category: ProductCategory.homeHealthCare,
      subType: HomeHealthCareType.bloodPressureMonitors,
      price: 49.99,
      imageUrl: 'https://via.placeholder.com/300x300/FF3B30/FFFFFF?text=BP+Monitor',
      features: [
        'One-touch operation',
        'Irregular heartbeat detection',
        'Stores 120 readings',
        'Large LCD display',
        'Adjustable cuff',
      ],
      stockQuantity: 40,
      color: Colors.grey,
      colorName: 'White',
      alternativeProductIds: const [],
      upgradeProductIds: const [],
      // 💡 NEW TAG
      hasSameDayDelivery: true,
    ),
  ];

  // ----------------------------------------------------------------------
  // HELPER METHOD
  // ----------------------------------------------------------------------

  static Product? getProductById(String id) {
    try {
      return productCatalog.firstWhere((p) => p.id == id);
    } catch (e) {
      // Return null if the product ID is not found
      return null;
    }
  }

  // ----------------------------------------------------------------------
  // (EXISTING METHODS)
  // ----------------------------------------------------------------------

  // Get products by category
  static List<Product> getProductsByCategory(ProductCategory category) {
    return productCatalog
        .where((Product p) => p.category == category)
        .toList();
  }

  // Get products by subtype
  static List<Product> getProductsBySubType(dynamic subType) {
    return productCatalog
        .where((Product p) => p.subType == subType)
        .toList();
  }

  // Kiosk timeout
  static const Duration kioskTimeout = Duration(minutes: 3);

  // Currency
  static const String currencySymbol = r'$';

  // Contact
  static const String supportPhone = '1-800-MEDIHUB';
  static const String supportEmail = 'support@medihub.health';
}