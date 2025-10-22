import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/cart_api_service.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => List.unmodifiable(_items);
  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(Product product) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Fetch cart products from API
  Future<void> fetchCartProducts(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await CartApiService.getCartProducts(phoneNumber);
      _items.clear();

      // Convert products to cart items using backend data
      for (final product in products) {
        // Ensure required fields are not null
        final productId = product['product_id'];
        final productName = product['name'];
        final originalPrice = product['price'];
        final discountPrice = product['discount_price'];
        final quantity = product['quantity'];

        if (productId == null || productName == null || originalPrice == null) {
          continue; // Skip invalid products
        }

        // Create a product object with discount information
        final productModel = Product(
          id: productId.toString(),
          name: productName.toString(),
          image: 'assets/icons/barcode_scanner.svg', // Default image
          originalPrice: (originalPrice is num)
              ? originalPrice.toDouble()
              : 0.0,
          discountPrice:
              (discountPrice != null &&
                  discountPrice != originalPrice &&
                  discountPrice is num)
              ? discountPrice.toDouble()
              : null,
          stock: 0, // Not needed for cart display
          category: 'General',
          description: null,
        );

        // Use quantity from backend, default to 1 if null
        final itemQuantity = (quantity is num) ? quantity.toInt() : 1;

        _items.add(CartItem(product: productModel, quantity: itemQuantity));
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add product to cart via API
  Future<bool> addProductToCart(String phoneNumber, String productId) async {
    try {
      final success = await CartApiService.addProductToCart(
        phoneNumber,
        productId,
      );
      if (success) {
        // Refresh cart data from API
        await fetchCartProducts(phoneNumber);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Remove product from cart via API
  Future<bool> removeProductFromCart(
    String phoneNumber,
    String productId,
  ) async {
    try {
      final success = await CartApiService.removeProductFromCart(
        phoneNumber,
        productId,
      );
      if (success) {
        // Refresh cart data from API
        await fetchCartProducts(phoneNumber);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void placeOrder(String paymentMethod) {
    if (_items.isEmpty) return;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(_items),
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      orderDate: DateTime.now(),
      status: 'completed',
    );

    _orders.add(order);
    _items.clear();
    notifyListeners();
  }
}
