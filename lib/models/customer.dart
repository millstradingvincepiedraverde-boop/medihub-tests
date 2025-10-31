import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customer extends ChangeNotifier {
  String email = '';
  String phone = '';
  String firstName = '';
  String lastName = '';
  String address = '';
  String apartment = ''; // mapped from your 'apt' controller
  String postcode = '';
  String city = '';
  String state = '';
  String deliveryMethod = 'standard'; // <<< ADDED

  String get fullName => '$firstName $lastName'.trim();

  bool get hasData =>
      email.isNotEmpty || phone.isNotEmpty || firstName.isNotEmpty;

  // --- 🧠 SESSION DATA (in-memory only, not persisted between restarts) ---
  static Customer? _sessionCustomer;

  /// ✅ Save this instance to in-memory session
  void saveToSession() {
    debugPrint('[Customer] 💾 Saving customer data to session...');
    _sessionCustomer = Customer()
      ..email = email
      ..phone = phone
      ..firstName = firstName
      ..lastName = lastName
      ..address = address
      ..apartment = apartment
      ..postcode = postcode
      ..city = city
      ..state = state
      ..deliveryMethod = deliveryMethod;

    debugPrint('[Customer] ✅ Session saved: ${jsonEncode(toMap())}');
  }

  /// ✅ Restore from session if available
  void loadFromSession() {
    debugPrint('[Customer] 🔁 Attempting to load session data...');
    if (_sessionCustomer == null) {
      debugPrint('[Customer] ⚠️ No session data found.');
      return;
    }

    email = _sessionCustomer!.email;
    phone = _sessionCustomer!.phone;
    firstName = _sessionCustomer!.firstName;
    lastName = _sessionCustomer!.lastName;
    address = _sessionCustomer!.address;
    apartment = _sessionCustomer!.apartment;
    postcode = _sessionCustomer!.postcode;
    city = _sessionCustomer!.city;
    state = _sessionCustomer!.state;
    deliveryMethod = _sessionCustomer!.deliveryMethod;

    debugPrint('[Customer] ✅ Session restored: ${jsonEncode(toMap())}');
    notifyListeners();
  }

  // --- EXISTING UPDATE LOGIC ---
  void update({
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? address,
    String? apartment,
    String? postcode,
    String? city,
    String? state,
    String? deliveryMethod, // <<< ADDED named param
  }) {
    debugPrint('[Customer] ✏️ Updating fields...');

    var changed = false;

    if (email != null && this.email != email) {
      debugPrint('  • email: "$email"');
      this.email = email;
      changed = true;
    }
    if (phone != null && this.phone != phone) {
      debugPrint('  • phone: "$phone"');
      this.phone = phone;
      changed = true;
    }
    if (firstName != null && this.firstName != firstName) {
      debugPrint('  • firstName: "$firstName"');
      this.firstName = firstName;
      changed = true;
    }
    if (lastName != null && this.lastName != lastName) {
      debugPrint('  • lastName: "$lastName"');
      this.lastName = lastName;
      changed = true;
    }
    if (address != null && this.address != address) {
      debugPrint('  • address: "$address"');
      this.address = address;
      changed = true;
    }
    if (apartment != null && this.apartment != apartment) {
      debugPrint('  • apartment: "$apartment"');
      this.apartment = apartment;
      changed = true;
    }
    if (postcode != null && this.postcode != postcode) {
      debugPrint('  • postcode: "$postcode"');
      this.postcode = postcode;
      changed = true;
    }
    if (city != null && this.city != city) {
      debugPrint('  • city: "$city"');
      this.city = city;
      changed = true;
    }
    if (state != null && this.state != state) {
      debugPrint('  • state: "$state"');
      this.state = state;
      changed = true;
    }
    if (deliveryMethod != null && this.deliveryMethod != deliveryMethod) {
      debugPrint('  • deliveryMethod: "$deliveryMethod"');
      this.deliveryMethod = deliveryMethod;
      changed = true;
    }

    if (changed) {
      debugPrint(
        '[Customer] ✅ Update complete. Current values: ${jsonEncode(toMap())}',
      );
      notifyListeners();
    } else {
      debugPrint('[Customer] ℹ️ No changes detected.');
    }
  }

  void reset() {
    debugPrint('[Customer] 🔄 Resetting all fields...');
    email = '';
    phone = '';
    firstName = '';
    lastName = '';
    address = '';
    apartment = '';
    postcode = '';
    city = '';
    state = '';
    deliveryMethod = 'standard';
    debugPrint('[Customer] ✅ Fields cleared.');
    notifyListeners();
  }

  // --- VALIDATION (unchanged) ---
  bool isValid() {
    final valid =
        email.isNotEmpty &&
        phone.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        address.isNotEmpty &&
        postcode.isNotEmpty;

    debugPrint(
      '[Customer] 🧾 Validation check: ${valid ? "✅ VALID" : "❌ INVALID"}',
    );
    return valid;
  }

  Map<String, String> getValidationErrors() {
    final errors = <String, String>{};
    if (email.isEmpty) errors['email'] = 'Email is required';
    if (phone.isEmpty) errors['phone'] = 'Phone is required';
    if (firstName.isEmpty) errors['firstName'] = 'First name is required';
    if (lastName.isEmpty) errors['lastName'] = 'Last name is required';
    if (address.isEmpty) errors['address'] = 'Address is required';
    if (postcode.isEmpty) errors['postcode'] = 'Postcode is required';

    if (errors.isNotEmpty) {
      debugPrint('[Customer] ⚠️ Validation errors: $errors');
    }
    return errors;
  }

  // --- Helper to print all data cleanly ---
  Map<String, String> toMap() => {
    'email': email,
    'phone': phone,
    'firstName': firstName,
    'lastName': lastName,
    'address': address,
    'apartment': apartment,
    'postcode': postcode,
    'city': city,
    'state': state,
    'deliveryMethod': deliveryMethod,
  };
}
