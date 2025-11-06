import 'dart:convert';
import 'package:http/http.dart' as http; // Or import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart'; // ✅ import your Customer model

class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final List<OrderItem> _cartItems = [];
  final List<Order> _orderHistory = [];

  // ✅ Customer data now only lives in memory for the session
  final Customer customer = Customer();

  bool isProductInCart(String productId) =>
      _cartItems.any((item) => item.product.id == productId);

  List<OrderItem> get cartItems => List.unmodifiable(_cartItems);
  List<Order> get orderHistory => List.unmodifiable(_orderHistory);

  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get cartTotal =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  // 🛒 CART MANAGEMENT --------------------------------------------------
  void addToCart(Product product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(OrderItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // 💾 CUSTOMER DATA (now saved in session storage) ---------------------
  Future<void> saveCustomerToSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', customer.email ?? '');
    await prefs.setString('phone', customer.phone ?? '');
    await prefs.setString('firstName', customer.firstName ?? '');
    await prefs.setString('lastName', customer.lastName ?? '');
    await prefs.setString('address', customer.address ?? '');
    await prefs.setString('apartment', customer.apartment ?? '');
    await prefs.setString('city', customer.city ?? '');
    await prefs.setString('state', customer.state ?? '');
    await prefs.setString('postcode', customer.postcode ?? '');
  }

  Future<void> loadCustomerFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    customer
      ..email = prefs.getString('email') ?? ''
      ..phone = prefs.getString('phone') ?? ''
      ..firstName = prefs.getString('firstName') ?? ''
      ..lastName = prefs.getString('lastName') ?? ''
      ..address = prefs.getString('address') ?? ''
      ..apartment = prefs.getString('apartment') ?? ''
      ..city = prefs.getString('city') ?? ''
      ..state = prefs.getString('state') ?? ''
      ..postcode = prefs.getString('postcode') ?? '';
    notifyListeners();
  }

  void clearCustomer() async {
    customer.reset();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  // 🧾 ORDER LOGIC -----------------------------------------------------
  Order placeOrder() {
    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(_cartItems),
      orderDate: DateTime.now(),
      customerName: customer.fullName,
      customerEmail: customer.email,
      customerPhone: customer.phone,
      deliveryAddress:
          '${customer.address}, ${customer.city}, ${customer.state} ${customer.postcode}',
    );

    _orderHistory.add(order);
    _cartItems.clear();
    notifyListeners();

    return order;
  }

  Future<void> syncCart() async {

    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(_cartItems),
      orderDate: DateTime.now(),
      customerName: customer.fullName,
      customerEmail: customer.email,
      customerPhone: customer.phone,
      deliveryAddress:
          '${customer.address}, ${customer.city}, ${customer.state} ${customer.postcode}',
    );

    final response = await http.post(
      Uri.parse('http://10.10.10.205:5173/api/v1/upsert-app-cart-shopify'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(order.toJson()),
    );

    if (response.statusCode == 201) {
      // Request successful, parse the JSON response
      final data = jsonDecode(response.body);
      print(data);
    } else {
      // Request failed
      throw Exception('Failed to create post');
    }
    print(order.toJson());
  }
}
