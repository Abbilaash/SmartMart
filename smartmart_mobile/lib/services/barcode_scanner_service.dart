import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'mock_data_service.dart';

class BarcodeScannerService {
  static Product? scanProductFromBarcode(String barcodeData) {
    try {
      // Parse barcode data - assuming barcode contains product ID
      // In real implementation, this would call your backend API
      final productId = barcodeData.trim();

      // For now, we'll use mock data to simulate product lookup
      final products = MockDataService.getProducts();
      final product = products.firstWhere(
        (product) => product.id == productId,
        orElse: () => throw Exception('Product not found'),
      );

      return product;
    } catch (e) {
      throw Exception('Invalid barcode or product not found');
    }
  }

  static String generateProductBarcode(String productId) {
    // In real implementation, this would generate a barcode for a product
    return productId;
  }

  static void invalidateProductBarcode(String productId) {
    // In real implementation, this would mark the barcode as used/invalid
    // For now, we'll just simulate this
    print('Barcode invalidated for product: $productId');
  }

  // Web-compatible barcode scanning simulation
  static Future<Product?> simulateBarcodeScan() async {
    // Simulate barcode scanning for web
    await Future.delayed(const Duration(seconds: 1));

    // Randomly select a product for demo
    final products = MockDataService.getProducts();
    final randomIndex = DateTime.now().millisecondsSinceEpoch % products.length;
    return products[randomIndex];
  }
}
