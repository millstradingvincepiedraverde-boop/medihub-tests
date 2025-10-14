import 'package:flutter/material.dart';

enum ProductCategory {
  wheelchairs,
  mobilityScooters,
  dailyLivingAids,
  homeHealthCare,
}

enum WheelchairType {
  manual,
  electric,
  sport,
  pediatric,
  bariatric,
  transport,
  reclining,
}

enum MobilityScooterType {
  travelScooter,
  heavyDuty,
  threeWheel,
  fourWheel,
  foldable,
}

enum DailyLivingAidType {
  walkingAids,
  bathroomSafety,
  reachersGrabbers,
  dressingAids,
  eatingAids,
}

enum HomeHealthCareType {
  hospital_beds,
  patientLifts,
  nebulizers,
  bloodPressureMonitors,
  oxygenConcentrators,
}

class Product {
  final String id;
  final String name;
  final String description;
  final ProductCategory category;
  final dynamic subType; // Can be WheelchairType, MobilityScooterType, etc.
  final double price;
  final String imageUrl;
  final List<String> features;
  final int stockQuantity;
  final double? weight;
  final double? maxUserWeight;
  final Color color;
  final String colorName;
  final bool hasSameDayDelivery;

  final List<String> alternativeProductIds; // Products that serve the same purpose (e.g., Forearm Crutch)
  final List<String> upgradeProductIds;     // Products/Accessories that enhance the current product (e.g., Shock-Absorbing Tips)


  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.subType,
    required this.price,
    required this.imageUrl,
    required this.features,
    required this.stockQuantity,
    this.weight,
    this.maxUserWeight,
    required this.color,
    required this.colorName,
     this.alternativeProductIds = const [], 
    this.upgradeProductIds = const [],
    this.hasSameDayDelivery = false,
  });

  bool get isInStock => stockQuantity > 0;

  String get categoryDisplayName {
    switch (category) {
      case ProductCategory.wheelchairs:
        return 'Wheelchairs';
      case ProductCategory.mobilityScooters:
        return 'Mobility Scooters';
      case ProductCategory.dailyLivingAids:
        return 'Daily Living Aids';
      case ProductCategory.homeHealthCare:
        return 'Home Health Care';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case ProductCategory.wheelchairs:
        return Icons.accessible;
      case ProductCategory.mobilityScooters:
        return Icons.electric_scooter;
      case ProductCategory.dailyLivingAids:
        return Icons.home;
      case ProductCategory.homeHealthCare:
        return Icons.medical_services;
    }
  }

  String get subTypeDisplayName {
    if (subType is WheelchairType) {
      switch (subType as WheelchairType) {
        case WheelchairType.manual:
          return 'Manual Wheelchair';
        case WheelchairType.electric:
          return 'Electric Wheelchair';
        case WheelchairType.sport:
          return 'Sport Wheelchair';
        case WheelchairType.pediatric:
          return 'Pediatric Wheelchair';
        case WheelchairType.bariatric:
          return 'Bariatric Wheelchair';
        case WheelchairType.transport:
          return 'Transport Chair';
        case WheelchairType.reclining:
          return 'Reclining Wheelchair';
      }
    } else if (subType is MobilityScooterType) {
      switch (subType as MobilityScooterType) {
        case MobilityScooterType.travelScooter:
          return 'Travel Scooter';
        case MobilityScooterType.heavyDuty:
          return 'Heavy Duty Scooter';
        case MobilityScooterType.threeWheel:
          return '3-Wheel Scooter';
        case MobilityScooterType.fourWheel:
          return '4-Wheel Scooter';
        case MobilityScooterType.foldable:
          return 'Foldable Scooter';
      }
    } else if (subType is DailyLivingAidType) {
      switch (subType as DailyLivingAidType) {
        case DailyLivingAidType.walkingAids:
          return 'Walking Aids';
        case DailyLivingAidType.bathroomSafety:
          return 'Bathroom Safety';
        case DailyLivingAidType.reachersGrabbers:
          return 'Reachers & Grabbers';
        case DailyLivingAidType.dressingAids:
          return 'Dressing Aids';
        case DailyLivingAidType.eatingAids:
          return 'Eating Aids';
      }
    } else if (subType is HomeHealthCareType) {
      switch (subType as HomeHealthCareType) {
        case HomeHealthCareType.hospital_beds:
          return 'Hospital Beds';
        case HomeHealthCareType.patientLifts:
          return 'Patient Lifts';
        case HomeHealthCareType.nebulizers:
          return 'Nebulizers';
        case HomeHealthCareType.bloodPressureMonitors:
          return 'Blood Pressure Monitors';
        case HomeHealthCareType.oxygenConcentrators:
          return 'Oxygen Concentrators';
      }
    }
    return 'Product';
  }

  IconData get subTypeIcon {
    if (subType is WheelchairType) {
      switch (subType as WheelchairType) {
        case WheelchairType.manual:
          return Icons.accessible;
        case WheelchairType.electric:
          return Icons.electric_scooter;
        case WheelchairType.sport:
          return Icons.sports;
        case WheelchairType.pediatric:
          return Icons.child_care;
        case WheelchairType.bariatric:
          return Icons.airline_seat_recline_extra;
        case WheelchairType.transport:
          return Icons.airport_shuttle;
        case WheelchairType.reclining:
          return Icons.event_seat;
      }
    } else if (subType is MobilityScooterType) {
      return Icons.electric_scooter;
    } else if (subType is DailyLivingAidType) {
      switch (subType as DailyLivingAidType) {
        case DailyLivingAidType.walkingAids:
          return Icons.accessible_forward;
        case DailyLivingAidType.bathroomSafety:
          return Icons.bathroom;
        case DailyLivingAidType.reachersGrabbers:
          return Icons.back_hand;
        case DailyLivingAidType.dressingAids:
          return Icons.checkroom;
        case DailyLivingAidType.eatingAids:
          return Icons.restaurant;
      }
    } else if (subType is HomeHealthCareType) {
      switch (subType as HomeHealthCareType) {
        case HomeHealthCareType.hospital_beds:
          return Icons.bed;
        case HomeHealthCareType.patientLifts:
          return Icons.elevator;
        case HomeHealthCareType.nebulizers:
          return Icons.air;
        case HomeHealthCareType.bloodPressureMonitors:
          return Icons.favorite;
        case HomeHealthCareType.oxygenConcentrators:
          return Icons.vaccines;
      }
    }
    return Icons.inventory;
  }
}