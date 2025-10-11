import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ecommerce_demo/src/model/product.dart';

class ProductService {
  final CollectionReference productsRef =
  FirebaseFirestore.instance.collection('products');

  // Stream products filtered by gender (category) and optional subcategory
  Stream<List<Product>> streamProducts({
    String? category,      // "men" or "women"
    String? subcategory,   // "clothing" or "shoes"
  }) {
    Query q = productsRef;
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    if (subcategory != null && subcategory.isNotEmpty) {
      q = q.where('subcategory', isEqualTo: subcategory);
    }
    return q.snapshots().map((snap) =>
        snap.docs.map((doc) => Product.fromMap(doc as Map<String, dynamic>)).toList(growable: false));
  }

  // Fetch single product by doc id (one-time)
  Future<Product?> getProductById(String id) async {
    final doc = await productsRef.doc(id).get();
    if (!doc.exists) return null;
    return Product.fromMap(doc as Map<String, dynamic>);
  }
}
