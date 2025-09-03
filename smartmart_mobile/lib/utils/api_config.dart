class ApiConfig {
  // Update this URL to match your backend server
  static const String baseUrl = 'https://endless-socially-bee.ngrok-free.app';

  // API endpoints
  static const String getCartProducts = '/users/carts/get_products';
  static const String addProductToCart = '/users/carts/add_product';
  static const String removeProductFromCart = '/users/carts/delete_product';
  static const String getProduct = '/products'; // Base endpoint for products
  static const String viewDiscounts = '/users/view_discounts';

  // Default phone number for testing (should be replaced with user authentication)
  static const String defaultPhoneNumber = '8667093591';

  // API timeout duration
  static const Duration timeout = Duration(seconds: 30);
}
