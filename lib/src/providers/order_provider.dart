import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/order.dart';
import '../model/product.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  OrderProvider() {
    loadOrders();
  }

  /// Load orders from SharedPreferences
  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersJson = prefs.getString('order_history');
    if (ordersJson != null) {
      final List<dynamic> decoded = jsonDecode(ordersJson);
      _orders.clear();
      _orders.addAll(decoded.map((e) => Order.fromMap(e)).toList());
      notifyListeners();
    }
  }

  /// Add new order and save to SharedPreferences
  Future<void> addOrder({
    required List<Product> products,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: products,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      date: DateTime.now(),
    );
    _orders.insert(0, newOrder);
    await _saveOrdersToPrefs();
    notifyListeners();
  }

  /// Clear all orders (e.g., on logout)
  Future<void> clearOrders() async {
    _orders.clear();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('order_history');
    notifyListeners();
  }

  /// Save orders to SharedPreferences
  Future<void> _saveOrdersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_orders.map((e) => e.toMap()).toList());
    await prefs.setString('order_history', encoded);
  }
}
