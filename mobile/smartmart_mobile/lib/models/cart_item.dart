import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Get total price for this item
  double get totalPrice => product.currentPrice * quantity;

  // Get total original price for this item
  double get totalOriginalPrice => product.originalPrice * quantity;

  // Get total savings for this item
  double get totalSavings => totalOriginalPrice - totalPrice;

  // Check if item has discount
  bool get hasDiscount => product.hasDiscount;

  // Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  // Convert CartItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  // Copy with method for creating modified copies
  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  // Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.product.id == product.id;
  }

  @override
  int get hashCode => product.id.hashCode;
} 