import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyPhone = 'phone_number';
  static const _keyPassword = 'password';
  static const _keyName = 'name';
  static const _keyRole = 'role';

  static Future<void> saveLogin({
    required String phoneNumber,
    required String password,
    String? name,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhone, phoneNumber);
    await prefs.setString(_keyPassword, password);
    if (name != null) await prefs.setString(_keyName, name);
    if (role != null) await prefs.setString(_keyRole, role);
  }

  static Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyPhone) && prefs.containsKey(_keyPassword);
  }

  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone);
  }

  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPassword);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyPassword);
    await prefs.remove(_keyName);
    await prefs.remove(_keyRole);
  }
}
