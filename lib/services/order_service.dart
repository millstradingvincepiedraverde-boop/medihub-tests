import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/order.dart';

class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final List<OrderItem> _cartItems = [];
  final List<Order> _orderHistory = [];

  bool isProductInCart(String productId) =>
      _cartItems.any((item) => item.product.id == productId);

  List<OrderItem> get cartItems => List.unmodifiable(_cartItems);
  List<Order> get orderHistory => List.unmodifiable(_orderHistory);

  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  void addToCart(Product product) {
    final existingIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(OrderItem(product: product));
    }
    notifyListeners(); // 👈 notify changes
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners(); // 👈
  }

  void updateQuantity(String productId, int quantity) {
    final index =
        _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
      notifyListeners(); // 👈
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners(); // 👈
  }

  Order placeOrder({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String deliveryAddress,
  }) {
    final order = Order(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(_cartItems),
      orderDate: DateTime.now(),
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
    );

    _orderHistory.add(order);
    _cartItems.clear();
    notifyListeners(); // 👈

    return order;
  }
}
