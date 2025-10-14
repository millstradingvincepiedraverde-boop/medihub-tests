class Customer {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? notes;

  Customer({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.notes,
  });

  bool get isValid {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        address.isNotEmpty;
  }
}