import 'product.dart';

enum OrderStatus { pending, confirmed, processing, completed, cancelled }

class OrderItem {
  final Product product;
  final String? sku; // ✅ Added SKU field
  int quantity;

  OrderItem({required this.product, this.quantity = 1})
    : sku = product.sku; // ✅ Automatically copy SKU from product

  double get totalPrice => product.price * quantity;
}

class Order {
  final String id;
  final List<OrderItem> items; // ✅ Typed list for safety
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
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// ✅ Optional: Convert order to JSON for sending to backend or Neto API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderDate': orderDate.toIso8601String(),
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'status': status.toString().split('.').last,
      'items': items.map((item) {
        return {
          'productId': item.product.id,
          'sku': item.sku, // ✅ SKU included here
          'name': item.product.name,
          'price': item.product.price,
          'quantity': item.quantity,
          'totalPrice': item.totalPrice,
        };
      }).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
    };
  }
}
