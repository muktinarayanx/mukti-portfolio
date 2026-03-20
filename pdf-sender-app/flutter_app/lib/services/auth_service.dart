import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';

  // ── Token helpers ──────────────────────────────────────────────────────────
  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<void> saveUser(UserModel user) =>
      _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

  static Future<UserModel?> getUser() async {
    final data = await _storage.read(key: _userKey);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  static Future<void> clearStorage() => _storage.deleteAll();

  // ── Register ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.registerEndpoint}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 201) {
      final user = UserModel.fromJson(body);
      await saveToken(user.token);
      await saveUser(user);
      return {'success': true, 'user': user};
    }
    return {'success': false, 'message': body['message'] ?? 'Registration failed'};
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final user = UserModel.fromJson(body);
      await saveToken(user.token);
      await saveUser(user);
      return {'success': true, 'user': user};
    }
    return {'success': false, 'message': body['message'] ?? 'Login failed'};
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  static Future<void> logout() => clearStorage();
}
