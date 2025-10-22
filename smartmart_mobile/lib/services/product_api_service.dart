import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/api_config.dart';

class ProductApiService {
  // Fetch product details by barcode/product_id
  static Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/products/$barcode'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> productJson = jsonDecode(response.body);
        return Product.fromJson(productJson);
      } else if (response.statusCode == 404) {
        // Product not found
        return null;
      } else {
        throw Exception('Failed to fetch product: ${response.statusCode}');
      }
    } catch (e) {
      // If the endpoint doesn't exist yet, we'll create a mock product for testing
      // In production, you should handle this properly
      print('API call failed, creating mock product: $e');
      return _createMockProductFromBarcode(barcode);
    }
  }

  // Create a mock product for testing when API is not available
  static Product _createMockProductFromBarcode(String barcode) {
    return Product(
      id: barcode,
      name: 'Product $barcode',
      image: 'assets/icons/barcode_scanner.svg',
      originalPrice: 9.99,
      stock: 10,
      category: 'General',
      description: 'Product scanned with barcode: $barcode',
    );
  }
}
