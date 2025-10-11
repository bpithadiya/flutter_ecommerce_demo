import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Product> _wishlist = [];

  List<Product> get wishlist => _wishlist;

  WishlistProvider() {
    loadWishlist();
  }

  /// Load wishlist from SharedPreferences
  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? wishlistJson = prefs.getString('wishlist_data');
    if (wishlistJson != null) {
      final List<dynamic> decoded = jsonDecode(wishlistJson);
      _wishlist.clear();
      _wishlist.addAll(decoded.map((e) => Product.fromMap(e)).toList());
      notifyListeners();
    }
  }

  /// Add product to wishlist and save to SharedPreferences
  Future<void> addToWishlist(Product product) async {
    if (!_wishlist.any((p) => p.id == product.id)) {
      _wishlist.add(product);
      await _saveWishlistToPrefs();
      notifyListeners();
    }
  }

  /// Remove product from wishlist and update SharedPreferences
  Future<void> removeFromWishlist(String productId) async {
    _wishlist.removeWhere((p) => p.id == productId);
    await _saveWishlistToPrefs();
    notifyListeners();
  }

  /// Clear wishlist (e.g., on logout)
  Future<void> clearWishlist() async {
    _wishlist.clear();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('wishlist_data');
    notifyListeners();
  }

  /// Save wishlist to SharedPreferences
  Future<void> _saveWishlistToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_wishlist.map((p) => p.toMap()).toList());
    await prefs.setString('wishlist_data', encoded);
  }
}


