import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class ChangePasswordService {
  static Future<Map<String, dynamic>> changePassword({
    required String phoneNumber,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/change_password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error changing password: ${e.toString()}',
      };
    }
  }
}
