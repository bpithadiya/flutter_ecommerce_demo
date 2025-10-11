import '../model/product.dart';

class Order {
  final String id;
  final List<Product> items;
  final double totalAmount;
  final String paymentMethod;
  final DateTime date;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((p) => p.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      items: List<Product>.from(
        (map['items'] as List).map((p) => Product.fromMap(p)),
      ),
      totalAmount: map['totalAmount'],
      paymentMethod: map['paymentMethod'],
      date: DateTime.parse(map['date']),
    );
  }
}
