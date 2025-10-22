import 'package:flutter/material.dart';
import '../models/product.dart';

class AppConstants {
  // // Define new product IDs for suggestions
  // static const String ID_ROLLATOR_WALKER = 'dla004'; // New Alternative
  // static const String ID_WALKER_CADDY = 'dla005'; // New Upgrade/Accessory

  // // Product catalog with all categories
  // static final List<Product> productCatalog = [
  //   // ----------------------------------------------------------------------
  //   // WHEELCHAIRS
  //   // ----------------------------------------------------------------------
  //   Product(
  //     id: 'wc001',
  //     sku: 'SKU_WC001', // ✅ Added SKU
  //     name: 'Standard Manual Wheelchair',
  //     description:
  //         'Durable steel frame wheelchair ideal for everyday use. Features padded armrests and footrests for maximum comfort.',
  //     category: ProductCategory.wheelchairs,
  //     subType: WheelchairType.manual,
  //     price: 299.00,
  //     imageUrl: 'assets/images/wheelchairs/wheelchair-1.png',
  //     features: [
  //       'Steel frame construction',
  //       'Padded armrests and seat',
  //       'Swing-away footrests',
  //       'Desk-length armrests',
  //       '18" seat width',
  //     ],
  //     stockQuantity: 20,
  //     color: Colors.blue,
  //     colorName: 'Black',
  //     alternativeProductIds: const ['dla005'],
  //     upgradeProductIds: const [],
  //     hasSameDayDelivery: true,
  //   ),
  //   Product(
  //     id: 'wc002',
  //     sku: 'SKU_WC002',
  //     name: 'Electric Power Wheelchair',
  //     description:
  //         'Advanced motorized wheelchair with joystick control. Long-lasting battery for extended use.',
  //     category: ProductCategory.wheelchairs,
  //     subType: WheelchairType.electric,
  //     price: 1850.00,
  //     imageUrl: 'assets/images/wheelchairs/wheelchair-2.png',
  //     features: [
  //       'Joystick controller',
  //       '20km battery range',
  //       '360-degree turning radius',
  //       'USB charging port',
  //       'LED headlights',
  //     ],
  //     stockQuantity: 8,
  //     color: Colors.blue,
  //     colorName: 'Charcoal',
  //     hasSameDayDelivery: false,
  //   ),
  //   Product(
  //     id: 'wc003',
  //     sku: 'SKU_WC003',
  //     name: 'Transport Chair',
  //     description:
  //         'Companion-propelled transport wheelchair with smaller wheels. Ideal for attendant-assisted mobility.',
  //     category: ProductCategory.wheelchairs,
  //     subType: WheelchairType.transport,
  //     price: 199.00,
  //     imageUrl: 'assets/images/wheelchairs/wheelchair-3.png',
  //     features: [
  //       'Lightweight design (9kg)',
  //       'Companion hand brakes',
  //       'Fold-down back',
  //       'Carry handles',
  //     ],
  //     stockQuantity: 25,
  //     color: Colors.blue,
  //     colorName: 'Blue',
  //     hasSameDayDelivery: true,
  //   ),

  //   // ----------------------------------------------------------------------
  //   // MOBILITY SCOOTERS
  //   // ----------------------------------------------------------------------
  //   Product(
  //     id: 'ms001',
  //     sku: 'SKU_MS001',
  //     name: 'Compact Travel Scooter',
  //     description:
  //         'Lightweight and portable mobility scooter perfect for travel and shopping.',
  //     category: ProductCategory.mobilityScooters,
  //     subType: MobilityScooterType.travelScooter,
  //     price: 1299.00,
  //     imageUrl: 'assets/images/mobilityscooters/scooters-1.png',
  //     features: [
  //       'Disassembles into 5 pieces',
  //       '15km range per charge',
  //       'Fits in car trunk',
  //       'LED headlight',
  //       'Storage basket included',
  //     ],
  //     stockQuantity: 12,
  //     color: Colors.green,
  //     colorName: 'Red',
  //     hasSameDayDelivery: false,
  //   ),
  //   Product(
  //     id: 'ms002',
  //     sku: 'SKU_MS002',
  //     name: 'Heavy Duty 4-Wheel Scooter',
  //     description:
  //         'Robust mobility scooter with enhanced weight capacity and all-terrain capability.',
  //     category: ProductCategory.mobilityScooters,
  //     subType: MobilityScooterType.heavyDuty,
  //     price: 2499.00,
  //     imageUrl: 'assets/images/mobilityscooters/scooters-1.png',
  //     features: [
  //       'Up to 180kg weight capacity',
  //       '40km range',
  //       'Pneumatic tires',
  //       'Captain seat with armrests',
  //       'Digital dashboard',
  //     ],
  //     stockQuantity: 6,
  //     color: Colors.green,
  //     colorName: 'Black',
  //     hasSameDayDelivery: false,
  //   ),
  //   Product(
  //     id: 'ms003',
  //     sku: 'SKU_MS003',
  //     name: 'Foldable Mobility Scooter',
  //     description:
  //         'Ultra-compact folding scooter with automatic folding mechanism.',
  //     category: ProductCategory.mobilityScooters,
  //     subType: MobilityScooterType.foldable,
  //     price: 1799.00,
  //     imageUrl: 'assets/images/mobilityscooters/scooters-1.png',
  //     features: [
  //       'One-button auto-fold',
  //       '12kg lightweight',
  //       'Airline approved',
  //       'LED lights front & rear',
  //     ],
  //     stockQuantity: 10,
  //     color: Colors.green,
  //     colorName: 'Silver',
  //     hasSameDayDelivery: false,
  //   ),

  //   // ----------------------------------------------------------------------
  //   // DAILY LIVING AIDS
  //   // ----------------------------------------------------------------------
  //   Product(
  //     id: 'dla001',
  //     sku: 'SKU_DLA001',
  //     name: 'Folding Walker with Wheels',
  //     description:
  //         'Adjustable height walker with front wheels for easy maneuverability.',
  //     category: ProductCategory.dailyLivingAids,
  //     subType: DailyLivingAidType.walkingAids,
  //     price: 89.00,
  //     imageUrl: 'assets/images/dailyaids/dailyaids-1.png',
  //     features: [
  //       'Height adjustable',
  //       'Folds for storage',
  //       '5-inch front wheels',
  //       'Rear glide feet',
  //       'Tool-free assembly',
  //     ],
  //     stockQuantity: 30,
  //     color: Colors.pink,
  //     colorName: 'Silver',
  //     alternativeProductIds: [ID_ROLLATOR_WALKER],
  //     upgradeProductIds: [ID_WALKER_CADDY],
  //     hasSameDayDelivery: true,
  //   ),
  //   Product(
  //     id: 'dla002',
  //     sku: 'SKU_DLA002',
  //     name: 'Shower Chair with Back',
  //     description:
  //         'Durable shower chair with non-slip rubber tips for bathroom safety.',
  //     category: ProductCategory.dailyLivingAids,
  //     subType: DailyLivingAidType.bathroomSafety,
  //     price: 65.00,
  //     imageUrl: 'assets/images/dailyaids/dailyaids-1.png',
  //     features: [
  //       'Height adjustable legs',
  //       'Padded seat and back',
  //       'Drainage holes',
  //       'Rust-resistant aluminum',
  //       'Tool-free assembly',
  //     ],
  //     stockQuantity: 25,
  //     color: Colors.pink,
  //     colorName: 'White',
  //     hasSameDayDelivery: false,
  //   ),
  //   Product(
  //     id: 'dla003',
  //     sku: 'SKU_DLA003',
  //     name: 'Reacher Grabber Tool 32"',
  //     description:
  //         'Long reach grabber tool with ergonomic handle and rotating head.',
  //     category: ProductCategory.dailyLivingAids,
  //     subType: DailyLivingAidType.reachersGrabbers,
  //     price: 24.99,
  //     imageUrl: 'assets/images/dailyaids/dailyaids-1.png',
  //     features: [
  //       '32-inch reach',
  //       'Rotating jaw',
  //       'Magnetic tip',
  //       'Lightweight design',
  //       'Ergonomic trigger',
  //     ],
  //     stockQuantity: 50,
  //     color: Colors.pink,
  //     colorName: 'Blue',
  //     hasSameDayDelivery: true,
  //   ),
  //   Product(
  //     id: ID_ROLLATOR_WALKER,
  //     sku: 'SKU_DLA004',
  //     name: '4-Wheel Rollator with Seat',
  //     description:
  //         'Premium rollator with four wheels, hand brakes, a seat, and under-seat storage.',
  //     category: ProductCategory.dailyLivingAids,
  //     subType: DailyLivingAidType.walkingAids,
  //     price: 139.00,
  //     imageUrl: 'assets/images/dailyaids/dailyaids-1.png',
  //     features: [
  //       'Smooth-rolling 6-inch wheels',
  //       'Loop-lock hand brakes',
  //       'Padded seat and backrest',
  //       'Folding design',
  //       'Storage basket',
  //     ],
  //     stockQuantity: 15,
  //     color: Colors.pink,
  //     colorName: 'Red',
  //     hasSameDayDelivery: false,
  //   ),
  //   Product(
  //     id: ID_WALKER_CADDY,
  //     sku: 'SKU_DLA005',
  //     name: 'Walker Storage Caddy',
  //     description:
  //         'Convenient clip-on storage bag for walkers, includes cup holder.',
  //     category: ProductCategory.dailyLivingAids,
  //     subType: DailyLivingAidType.reachersGrabbers,
  //     price: 29.99,
  //     imageUrl: 'assets/images/dailyaids/dailyaids-1.png',
  //     features: [
  //       'Universal fit',
  //       'Two mesh pockets',
  //       'Integrated cup holder',
  //       'Durable nylon material',
  //     ],
  //     stockQuantity: 50,
  //     color: Colors.pink,
  //     colorName: 'Black',
  //     hasSameDayDelivery: true,
  //   ),

  //   // ----------------------------------------------------------------------
  //   // HOME HEALTH CARE
  //   // ----------------------------------------------------------------------
  //   Product(
  //     id: 'hhc001',
  //     sku: 'SKU_HHC001',
  //     name: 'Semi-Electric Hospital Bed',
  //     description:
  //         'Adjustable hospital bed with electric head and foot sections.',
  //     category: ProductCategory.homeHealthCare,
  //     subType: HomeHealthCareType.hospital_beds,
  //     price: 1899.00,
  //     imageUrl: 'assets/images/homecare/homecare-1.png',
  //     features: [
  //       'Electric head & foot adjustment',
  //       'Side rails included',
  //       'Tool-free assembly',
  //       'Weight capacity 200kg',
  //       'Quiet motors',
  //     ],
  //     stockQuantity: 5,
  //     color: Colors.grey,
  //     colorName: 'Beige',
  //     hasSameDayDelivery: false,
  //   ),
  //   Product(
  //     id: 'hhc002',
  //     sku: 'SKU_HHC002',
  //     name: 'Portable Oxygen Concentrator',
  //     description:
  //         'Lightweight portable oxygen concentrator for home and travel use.',
  //     category: ProductCategory.homeHealthCare,
  //     subType: HomeHealthCareType.oxygenConcentrators,
  //     price: 2299.00,
  //     imageUrl: 'assets/images/homecare/homecare-1.png',
  //     features: [
  //       'Pulse dose delivery',
  //       'Up to 5 liters per minute',
  //       'Battery powered',
  //       'Carry bag included',
  //       'FAA approved',
  //     ],
  //     stockQuantity: 8,
  //     color: Colors.grey,
  //     colorName: 'White',
  //     hasSameDayDelivery: false,
  //   ),
  //   Product(
  //     id: 'hhc003',
  //     sku: 'SKU_HHC003',
  //     name: 'Digital Blood Pressure Monitor',
  //     description:
  //         'Automatic blood pressure monitor with large LCD display and memory function.',
  //     category: ProductCategory.homeHealthCare,
  //     subType: HomeHealthCareType.bloodPressureMonitors,
  //     price: 49.99,
  //     imageUrl: 'assets/images/homecare/homecare-1.png',
  //     features: [
  //       'One-touch operation',
  //       'Irregular heartbeat detection',
  //       'Stores 120 readings',
  //       'Large LCD display',
  //       'Adjustable cuff',
  //     ],
  //     stockQuantity: 40,
  //     color: Colors.grey,
  //     colorName: 'White',
  //     hasSameDayDelivery: true,
  //   ),
  // ];

  // // ----------------------------------------------------------------------
  // // HELPER METHODS
  // // ----------------------------------------------------------------------
  // static Product? getProductById(String id) {
  //   try {
  //     return productCatalog.firstWhere((p) => p.id == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // static List<Product> getProductsByCategory(ProductCategory category) {
  //   return productCatalog.where((p) => p.category == category).toList();
  // }

  // static List<Product> getProductsBySubType(dynamic subType) {
  //   return productCatalog.where((p) => p.subType == subType).toList();
  // }

  // Constants
  static const Duration kioskTimeout = Duration(minutes: 3);
  static const String currencySymbol = r'$';
  static const String supportPhone = '1-800-MEDIHUB';
  static const String supportEmail = 'support@medihub.health';
}
