import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class PaymentsApiService {
  static Future<List<Map<String, dynamic>>> getPayments(String userId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users/payments/get_payments');
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId}),
        )
        .timeout(ApiConfig.timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final List payments = data['payments'] ?? [];
      return payments.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to fetch payments');
  }
}
