import '../models/product.dart';
import '../models/order.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final List _cartItems = [];
  final List _orderHistory = [];


   bool isProductInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  List get cartItems => List.unmodifiable(_cartItems);
  List get orderHistory => List.unmodifiable(_orderHistory);

  int get cartItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity as int);
  }

  double get cartTotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void addToCart(Product product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(OrderItem(product: product));
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
    }
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

    return order;
  }

  void clearCart() {
    _cartItems.clear();
  }
}