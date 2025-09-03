import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class AuthApiService {
  static Future<Map<String, dynamic>> signup({
    required String phoneNumber,
    required String password,
    String? name,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users/signup');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phoneNumber,
        'password': password,
        if (name != null && name.isNotEmpty) 'name': name,
      }),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body['message'] ?? 'Signup failed');
  }

  static Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/users/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phoneNumber, 'password': password}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body['message'] ?? 'Login failed');
  }
}
