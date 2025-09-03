import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'mock_data_service.dart';

class BarcodeScannerService {
  static Product? scanProductFromBarcode(String barcodeData) {
    try {
      // Parse barcode data - in real implementation, this would call your backend API
      final barcode = barcodeData.trim();
      
      // For demo purposes, we'll accept any barcode and map it to a product
      // In a real app, this would query a database with the actual barcode
      final products = MockDataService.getProducts();
      
      // Create a simple hash-based mapping to consistently map barcodes to products
      final hash = barcode.hashCode.abs();
      final productIndex = hash % products.length;
      
      return products[productIndex];
    } catch (e) {
      throw Exception('Invalid barcode or product not found');
    }
  }

  static String generateProductBarcode(String productId) {
    // Generate a realistic-looking barcode for demo purposes
    // In real implementation, this would generate a proper barcode
    const baseBarcode = '1234567890123'; // 13-digit EAN-13 format
    final productNum = int.tryParse(productId) ?? 1;
    return '${baseBarcode.substring(0, 12)}$productNum';
  }

  static void invalidateProductBarcode(String productId) {
    // In real implementation, this would mark the barcode as used/invalid
    // For now, we'll just simulate this
    debugPrint('Barcode invalidated for product: $productId');
  }

  // Web-compatible barcode scanning simulation
  static Future<Product?> simulateBarcodeScan() async {
    // Simulate barcode scanning for web
    await Future.delayed(const Duration(seconds: 1));

    // Generate a random barcode and map it to a product
    final randomBarcode = '${DateTime.now().millisecondsSinceEpoch}';
    return scanProductFromBarcode(randomBarcode);
  }
}
