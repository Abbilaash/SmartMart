class Product {
  final String id;
  final String name;
  final String image;
  final double originalPrice;
  final double? discountPrice;
  final int stock;
  final String category;
  final String? description;
  final bool isDiscounted;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.originalPrice,
    this.discountPrice,
    required this.stock,
    required this.category,
    this.description,
  }) : isDiscounted = discountPrice != null && discountPrice < originalPrice;

  double get currentPrice => discountPrice ?? originalPrice;
  double get discountPercentage => isDiscounted
      ? ((originalPrice - discountPrice!) / originalPrice * 100).roundToDouble()
      : 0.0;

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle backend discount data
    double? discountPrice;
    if (json['discount_price'] != null) {
      discountPrice = json['discount_price'].toDouble();
    } else if (json['discountPrice'] != null) {
      discountPrice = json['discountPrice'].toDouble();
    }
    
    return Product(
      id: json['product_id'] ?? json['id'], // Support both backend and frontend formats
      name: json['name'] ?? '',
      image: json['image'] ?? 'assets/icons/barcode_scanner.svg', // Default image
      originalPrice: (json['price'] ?? json['originalPrice'] ?? 0.0).toDouble(),
      discountPrice: discountPrice,
      stock: json['stock'] ?? json['stck_qty'] ?? 0, // Support both stock and stck_qty
      category: json['category'] ?? 'General',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'originalPrice': originalPrice,
      'discountPrice': discountPrice,
      'stock': stock,
      'category': category,
      'description': description,
    };
  }
}
