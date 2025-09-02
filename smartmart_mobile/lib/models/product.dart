
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
    return Product(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      originalPrice: json['originalPrice'].toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      stock: json['stock'],
      category: json['category'],
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
