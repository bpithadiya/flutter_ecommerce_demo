import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../model/product.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/custom_appbar.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    final isInCart = cartProvider.items.containsKey(product.id);
    final isInWishlist = wishlistProvider.wishlist.any((p) => p.id == product.id);

    return Scaffold(
      appBar: CustomAppBar(title: product.title),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(product.images),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${product.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Category: ${product.category.toUpperCase()} • ${product.subcategory}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : "No description available.",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInCart ? Colors.grey : Colors.deepPurple,
                          ),
                          icon: Icon(isInCart ? Icons.check : Icons.add_shopping_cart,color: Colors.white),
                          label: Text(isInCart ? "Added" : "Add to Cart",style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            if (!isInCart) {
                              cartProvider.addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Product added to cart")),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInWishlist ? Colors.grey : Colors.redAccent,
                        ),
                        icon: Icon(isInWishlist ? Icons.favorite : Icons.favorite_border,color: Colors.white,),
                        label: Text(isInWishlist ? "In Wishlist" : "Add to Wishlist",style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          if (!isInWishlist) {
                            wishlistProvider.addToWishlist(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Product added to wishlist")),
                            );
                          } else {
                            wishlistProvider.removeFromWishlist(product.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Product removed from wishlist")),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
      );
    }
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 350,
            enableInfiniteScroll: true,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() => _current = index);
            },
          ),
          items: images.map((url) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {},
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == entry.key
                      ? const Color(0xFF6A11CB)
                      : Colors.grey[400],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
