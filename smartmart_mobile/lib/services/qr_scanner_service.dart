import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'mock_data_service.dart';

class QRScannerService {
  static Product? scanProductFromQR(String qrData) {
    try {
      // Parse QR data - assuming QR contains product ID
      // In real implementation, this would call your backend API
      final productId = qrData.trim();
      
      // For now, we'll use mock data to simulate product lookup
      final products = MockDataService.getProducts();
      final product = products.firstWhere(
        (product) => product.id == productId,
        orElse: () => throw Exception('Product not found'),
      );
      
      return product;
    } catch (e) {
      throw Exception('Invalid QR code or product not found');
    }
  }

  static String generateProductQR(String productId) {
    // In real implementation, this would generate a QR code for a product
    return productId;
  }

  static void invalidateProductQR(String productId) {
    // In real implementation, this would mark the QR code as used/invalid
    // For now, we'll just simulate this
    debugPrint('QR code invalidated for product: $productId');
  }

  // Web-compatible QR scanning simulation
  static Future<Product?> simulateQRScan() async {
    // Simulate QR scanning for web
    await Future.delayed(const Duration(seconds: 1));
    
    // Randomly select a product for demo
    final products = MockDataService.getProducts();
    final randomIndex = DateTime.now().millisecondsSinceEpoch % products.length;
    return products[randomIndex];
  }
}
