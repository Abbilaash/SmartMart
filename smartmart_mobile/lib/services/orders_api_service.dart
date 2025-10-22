import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class OrdersApiService {
  static Future<List<Map<String, dynamic>>> getOrders(
    String phoneNumber,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getUserOrders}');
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone_number': phoneNumber}),
        )
        .timeout(ApiConfig.timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final List orders = data['orders'] ?? [];
      return orders.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to fetch orders');
  }

  static Future<Map<String, dynamic>> getOrderDetails(
    String phoneNumber,
    String orderId,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getOrderDetails}');
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phone_number': phoneNumber, 'order_id': orderId}),
        )
        .timeout(ApiConfig.timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch order details');
  }
}
