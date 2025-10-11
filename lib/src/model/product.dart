class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;     // "men" | "women"
  final String subcategory;  // "clothing" | "shoes"
  final List<String> images;
  final bool inStock;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.subcategory,
    required this.images,
    this.inStock = true,
  });

  factory Product.fromMap(Map<String, dynamic> data, [String? id]) {
    return Product(
      id: id ?? data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
    );
  }


  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'price': price,
    'category': category,
    'subcategory': subcategory,
    'images': images,
    'inStock': inStock,
  };
}
