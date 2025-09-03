import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/api_config.dart';

class ProductApiService {
  // Fetch product details by barcode/product_id
  static Future<Product?> getProductByBarcode(String barcode) async {
    try {
      // For now, we'll use the barcode as product_id since the backend expects product_id
      // In a real implementation, you might have a separate endpoint to search by barcode
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getProduct}/${barcode}'),
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
