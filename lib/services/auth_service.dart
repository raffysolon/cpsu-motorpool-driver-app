import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  static const String baseUrl = 'https://cpsumotorpool-backend.onrender.com/api';
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 401) {
      throw const AuthException('Email or password is incorrect.');
    }
    if (response.statusCode == 422) {
      throw const AuthException('Please check the email address and try again.');
    }
    if (response.statusCode == 429) {
      throw const AuthException(
        'Too many login attempts. Wait a minute and try again.',
      );
    }
    if (response.statusCode >= 500) {
      throw const AuthException(
        'The server could not complete the login. Please try again later.',
      );
    }
    if (response.statusCode != 200) {
      throw AuthException('Login failed (HTTP ${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const AuthException('The server returned no login token.');
    }

    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'role', value: data['role'] as String?);
    await _storage.write(key: 'name', value: data['name'] as String?);
    await _storage.write(key: 'email', value: email);
    return data;
  }

  static Future<String?> getToken() => _storage.read(key: 'auth_token');

  static Future<String?> getName() => _storage.read(key: 'name');

  static Future<String?> getEmail() => _storage.read(key: 'email');

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load profile');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to change password');
    }
  }

  static Future<void> logout() => _storage.deleteAll();
}