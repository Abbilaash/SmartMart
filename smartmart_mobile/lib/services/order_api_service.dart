import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class OrderApiService {
  // Place order from cart
  static Future<Map<String, dynamic>> placeOrder({
    required String phoneNumber,
    required String paymentMethod,
    String? billingAddress,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/orders/place_order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'payment_method': paymentMethod,
          if (billingAddress != null) 'billing_address': billingAddress,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      throw Exception('Error placing order: $e');
    }
  }

  // Get user orders
  static Future<List<Map<String, dynamic>>> getUserOrders(
    String phoneNumber,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/orders/get_orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['orders'] ?? []);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Get order details
  static Future<Map<String, dynamic>> getOrderDetails({
    required String phoneNumber,
    required String orderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/orders/get_order_details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phoneNumber, 'order_id': orderId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to fetch order details',
        );
      }
    } catch (e) {
      throw Exception('Error fetching order details: $e');
    }
  }
}
