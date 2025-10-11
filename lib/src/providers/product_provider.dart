import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';
import '../model/order.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  List<Product> _products = [];
  String? _currentCategory;
  String? _currentSubcategory;
  String? _errorMessage;
  bool _isLoading = false;

  // Wishlist & Orders persistence
  List<Product> _wishlist = [];
  List<Order> _orders = [];

  // Getters
  List<Product> get products => _products;
  String? get currentCategory => _currentCategory;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  List<Product> get wishlist => _wishlist;
  List<Order> get orders => _orders;

  ProductProvider() {
    _loadWishlist();
    _loadOrders();
  }

  /// Start listening to Firestore changes safely.
  void startListening({String? category, String? subcategory}) {
    _subscription?.cancel();
    _currentCategory = category;
    _currentSubcategory = subcategory;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Query<Map<String, dynamic>> query = _firestore.collection('products');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (subcategory != null) {
        query = query.where('subcategory', isEqualTo: subcategory);
      }

      _subscription = query.snapshots().listen(
            (snapshot) {
          if (!hasListeners) return;

          _products = snapshot.docs.map((doc) {
            return Product.fromMap(doc.data(), doc.id);
          }).toList();

          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (e) => _handleFirestoreError(e),
        cancelOnError: false,
      );
    } catch (e) {
      _handleFirestoreError(e);
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleFirestoreError(dynamic e) {
    _products = [];
    _isLoading = false;

    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          _errorMessage =
          'You don’t have permission to view these products.\nPlease check your Firestore rules or login again.';
          break;
        case 'unavailable':
          _errorMessage =
          'Network issue — please check your connection and try again.';
          break;
        default:
          _errorMessage = 'Firestore error: ${e.message ?? e.code}';
      }
    } else {
      _errorMessage = 'Unexpected error: $e';
    }

    debugPrint('🔥 Firestore Error: $_errorMessage');
    notifyListeners();
  }

  /// Wishlist persistence
  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = prefs.getString('wishlist_data');
    if (wishlistJson != null) {
      final List<dynamic> decoded = jsonDecode(wishlistJson);
      _wishlist = decoded.map((e) => Product.fromMap(e)).toList();
      notifyListeners();
    }
  }

  Future<void> addToWishlist(Product product) async {
    if (!_wishlist.any((p) => p.id == product.id)) {
      _wishlist.add(product);
      await _saveWishlist();
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    _wishlist.removeWhere((p) => p.id == productId);
    await _saveWishlist();
    notifyListeners();
  }

  Future<void> clearWishlist() async {
    _wishlist.clear();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('wishlist_data');
    notifyListeners();
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_wishlist.map((p) => p.toMap()).toList());
    await prefs.setString('wishlist_data', encoded);
  }

  /// Order history persistence
  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('orders_data');
    if (ordersJson != null) {
      final List<dynamic> decoded = jsonDecode(ordersJson);
      _orders = decoded.map((e) => Order.fromMap(e)).toList();
      notifyListeners();
    }
  }

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
    await _saveOrders();
    notifyListeners();
  }

  Future<void> clearOrders() async {
    _orders.clear();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('orders_data');
    notifyListeners();
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_orders.map((o) => o.toMap()).toList());
    await prefs.setString('orders_data', encoded);
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
