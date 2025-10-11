import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/custom_appbar.dart';
import 'product_detail.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(title: "My Wishlist"),
      body: wishlist.wishlist.isEmpty
          ? const Center(
        child: Text(
          "Your wishlist is empty 💔",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: wishlist.wishlist.length,
        itemBuilder: (ctx, i) {
          final product = wishlist.wishlist.toList()[i];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.images.isNotEmpty
                    ? Image.network(product.images[0], width: 60, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported, size: 60),
              ),
              title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text("\$${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  wishlist.removeFromWishlist(product.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Item removed from wishlist")),
                  );
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

