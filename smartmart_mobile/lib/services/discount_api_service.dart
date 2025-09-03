import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class DiscountApiService {
  static Future<List<Map<String, dynamic>>> getDiscounts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.viewDiscounts}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['discounts'] ?? []);
      } else {
        print('Failed to fetch discounts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching discounts: $e');
      return [];
    }
  }
}
