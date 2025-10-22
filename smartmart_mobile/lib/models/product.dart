class Product {
  final String id;
  final String name;
  final String image;
  final double originalPrice;
  final double? discountPrice;
  final int stock;
  final String category;
  final String? description;
  final String? discountName;
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
    this.discountName,
  }) : isDiscounted = discountPrice != null && discountPrice < originalPrice;

  double get currentPrice => discountPrice ?? originalPrice;
  double get discountPercentage => isDiscounted
      ? ((originalPrice - discountPrice!) / originalPrice * 100).roundToDouble()
      : 0.0;

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle backend discount data
    double? discountPrice;

    // Check if discount_price exists and is different from original price
    if (json['discount_price'] != null &&
        json['discount_price'] != json['price']) {
      discountPrice = json['discount_price'].toDouble();
    } else if (json['discountPrice'] != null) {
      discountPrice = json['discountPrice'].toDouble();
    }

    // If discount_percentage is available but discount_price is not calculated, calculate it
    if (discountPrice == null &&
        json['discount_percentage'] != null &&
        json['discount_percentage'] > 0) {
      double originalPrice = (json['price'] ?? json['originalPrice'] ?? 0.0)
          .toDouble();
      double discountPercent = json['discount_percentage'].toDouble();
      discountPrice = originalPrice * (1 - discountPercent / 100);
    }

    return Product(
      id: (json['product_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      image:
          (json['image_url'] ??
                  json['image'] ??
                  'assets/icons/barcode_scanner.svg')
              .toString(),
      originalPrice: ((json['price'] ?? json['originalPrice']) is num)
          ? (json['price'] ?? json['originalPrice']).toDouble()
          : 0.0,
      discountPrice: discountPrice,
      stock: ((json['stck_qty'] ?? json['stock']) is num)
          ? (json['stck_qty'] ?? json['stock']).toInt()
          : 0,
      category: (json['category'] ?? 'General').toString(),
      description: json['description']?.toString(),
      discountName: json['discount_name']?.toString(),
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
      'discountName': discountName,
    };
  }
}
