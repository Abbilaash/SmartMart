import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/api_config.dart';

class CartApiService {
  
  // Fetch products from cart
  static Future<List<Map<String, dynamic>>> getCartProducts(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getCartProducts}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> productsJson = data['products'] ?? [];
        
        // Return raw JSON data instead of converting to Product objects
        return productsJson.map((json) => Map<String, dynamic>.from(json)).toList();
      } else {
        throw Exception('Failed to fetch cart products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cart products: $e');
    }
  }

  // Add product to cart
  static Future<bool> addProductToCart(String phoneNumber, String productId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.addProductToCart}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'product_id': productId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error adding product to cart: $e');
    }
  }

  // Remove product from cart
  static Future<bool> removeProductFromCart(String phoneNumber, String productId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.removeProductFromCart}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'product_id': productId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error removing product from cart: $e');
    }
  }
}
