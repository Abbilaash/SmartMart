class Product {
  final String id;
  final String name;
  final String description;
  final double originalPrice;
  final double? discountPrice;
  final String category;
  final String imageUrl;
  final int stockQuantity;
  final bool isAvailable;
  final List<String> tags;
  final double? discountPercentage;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.originalPrice,
    this.discountPrice,
    required this.category,
    required this.imageUrl,
    required this.stockQuantity,
    required this.isAvailable,
    required this.tags,
    this.discountPercentage,
  });

  // Get the current price (discount price if available, otherwise original price)
  double get currentPrice => discountPrice ?? originalPrice;

  // Check if product has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < originalPrice;

  // Calculate discount percentage
  double? get calculatedDiscountPercentage {
    if (!hasDiscount) return null;
    return ((originalPrice - discountPrice!) / originalPrice * 100).roundToDouble();
  }

  // Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      originalPrice: json['originalPrice'].toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      category: json['category'],
      imageUrl: json['imageUrl'],
      stockQuantity: json['stockQuantity'],
      isAvailable: json['isAvailable'],
      tags: List<String>.from(json['tags']),
      discountPercentage: json['discountPercentage']?.toDouble(),
    );
  }

  // Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'originalPrice': originalPrice,
      'discountPrice': discountPrice,
      'category': category,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
      'isAvailable': isAvailable,
      'tags': tags,
      'discountPercentage': discountPercentage,
    };
  }

  // Copy with method for creating modified copies
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? originalPrice,
    double? discountPrice,
    String? category,
    String? imageUrl,
    int? stockQuantity,
    bool? isAvailable,
    List<String>? tags,
    double? discountPercentage,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      tags: tags ?? this.tags,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }
} 