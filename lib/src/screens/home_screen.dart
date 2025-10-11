import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_demo/src/providers/cart_provider.dart';
import 'package:flutter_ecommerce_demo/src/providers/wishlist_provider.dart';
import 'package:flutter_ecommerce_demo/src/screens/cart_screen.dart';
import 'package:flutter_ecommerce_demo/src/screens/profile_screen.dart';
import 'package:flutter_ecommerce_demo/src/screens/wishlist_screen.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../model/product.dart';
import '../widgets/badge_icon.dart';
import '../widgets/product_card.dart';
import 'product_detail.dart';

class HomeScreen extends StatefulWidget {
  final bool reload;
  const HomeScreen({Key? key, this.reload = false}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _hasReloaded = false; // new flag
  final tabs = ['All', 'Clothing', 'Shoes'];

  late ProductProvider _productProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _productProvider = Provider.of<ProductProvider>(context, listen: false);
        _productProvider.startListening(category: 'men');
      }
    });
  }

  @override
  void dispose() {
    try {
      _productProvider.stopListening();
    } catch (_) {}
    _tabController.dispose();
    super.dispose();
  }

  void _onGenderSwitched(String gender) {
    if (!mounted) return;
    Provider.of<ProductProvider>(context, listen: false)
        .startListening(category: gender);
  }

  Future<void> _UserSettings() async {
    //Setting Functionalities
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black12,
        centerTitle: true,
        title: const Text(
          "ShopEase",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurpleAccent,
            tabs: tabs.map((t) => Tab(text: t)).toList(),
            onTap: (i) {
              String? sub;
              if (i == 0) sub = null;
              else if (i == 1) sub = 'clothing';
              else sub = 'shoes';
              provider.startListening(
                category: provider.currentCategory,
                subcategory: sub,
              );
            },
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onGenderSwitched,
            color: Colors.white,
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'men',
                child: Row(
                  children: [
                    Icon(Icons.male, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Men'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'women',
                child: Row(
                  children: [
                    Icon(Icons.female, color: Colors.pink),
                    SizedBox(width: 8),
                    Text('Women'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            tooltip: 'Settings',
            onPressed: _UserSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        )
            : provider.products.isEmpty
            ? const Center(
          child: Text(
            "No products found.",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        )
            : GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: provider.products.length,
          itemBuilder: (context, idx) {
            final p = provider.products[idx];
            return ProductCard(product: p,);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BadgeIcon(
              heroTag: "wishlist",
              icon: Icons.favorite_border,
              iconColor: Colors.redAccent,
              badgeColor: Colors.redAccent,
              count: wishlistProvider.wishlist.length,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                );
              },
            ),
            const SizedBox(width: 10),
            BadgeIcon(
              heroTag: "cart",
              icon: Icons.shopping_cart_outlined,
              iconColor: Colors.deepPurple,
              badgeColor: Colors.deepPurpleAccent,
              count: cartProvider.items.length,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(BuildContext context, Product p) {
    final thumb = p.images.isNotEmpty ? p.images[0] : null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
      ),
      child: Hero(
        tag: p.id ?? p.title,
        child: Card(
          elevation: 6,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              thumb != null
                  ? Image.network(
                thumb,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
                  : Container(color: Colors.grey[300]),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "\$${p.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .addItem(p);
                          },
                          child: const Text(
                            "Add to Cart",
                            style:
                            TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.reload && !_hasReloaded) {
      _hasReloaded = true; // mark as done
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ProductProvider>(context, listen: false)
            .startListening(category: 'men');
      });
    }
  }

}