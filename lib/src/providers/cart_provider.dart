import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  double get totalPrice => _items.values
      .fold(0, (sum, item) => sum + item.product.price * item.quantity);

  CartProvider() {
    loadCartFromPrefs();
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id!] = CartItem(product: product, quantity: 1);
    }
    saveCartToPrefs();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    saveCartToPrefs();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    saveCartToPrefs();
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      saveCartToPrefs();
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (_items.containsKey(productId) && _items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }
    saveCartToPrefs();
    notifyListeners();
  }

  // Save cart to SharedPreferences
  Future<void> saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = _items.map((key, value) => MapEntry(
        key,
        jsonEncode({
          'product': value.product.toMap(),
          'quantity': value.quantity,
        })));
    await prefs.setString('cart', jsonEncode(cartData));
  }

  // Load cart from SharedPreferences
  Future<void> loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('cart')) {
      final decoded = jsonDecode(prefs.getString('cart')!) as Map<String, dynamic>;
      _items.clear();
      decoded.forEach((key, value) {
        final itemMap = jsonDecode(value);
        _items[key] = CartItem(
          product: Product.fromMap(itemMap['product'], key),
          quantity: itemMap['quantity'],
        );
      });
      notifyListeners();
    }
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}



