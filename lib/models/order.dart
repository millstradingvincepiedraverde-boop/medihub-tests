import 'product.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  completed,
  cancelled,
}

class OrderItem {
  final Product product;
  int quantity;

  OrderItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class Order {
  final String id;
  final List items;
  final DateTime orderDate;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String deliveryAddress;
  OrderStatus status;

  Order({
    required this.id,
    required this.items,
    required this.orderDate,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.deliveryAddress,
    this.status = OrderStatus.pending,
  });

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get tax => subtotal * 0.12; // 12% tax

  double get total => subtotal + tax;

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity as int);
  }
}