import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalSavings => _items.fold(0.0, (sum, item) => sum + item.totalSavings);

  double get tax => subtotal * 0.08; // 8% tax

  double get total => subtotal + tax;

  bool get isEmpty => _items.isEmpty;

  // Add item to cart
  void addItem(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      // Item already exists, increase quantity
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      // Add new item
      _items.add(CartItem(product: product, quantity: quantity));
    }
    
    notifyListeners();
  }

  // Remove item from cart
  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get quantity of product in cart
  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(
        id: '',
        name: '',
        description: '',
        originalPrice: 0,
        category: '',
        imageUrl: '',
        stockQuantity: 0,
        isAvailable: false,
        tags: [],
      )),
    );
    return item.quantity;
  }
} 