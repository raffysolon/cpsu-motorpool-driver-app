import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  static String get baseUrl => ApiConfig.apiBaseUrl;
  static const _storage = FlutterSecureStorage();
  static String get _tokenKey => '${ApiConfig.storageNamespace}:auth_token';
  static String get _roleKey => '${ApiConfig.storageNamespace}:role';
  static String get _nameKey => '${ApiConfig.storageNamespace}:name';
  static String get _emailKey => '${ApiConfig.storageNamespace}:email';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http
        .post(
          ApiConfig.apiUri('login'),
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
      throw const AuthException(
        'Please check the email address and try again.',
      );
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

    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : data;
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: user['role']?.toString());
    await _storage.write(key: _nameKey, value: user['name']?.toString());
    await _storage.write(
      key: _emailKey,
      value: user['email']?.toString() ?? email,
    );
    return data;
  }

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<String?> getName() => _storage.read(key: _nameKey);

  static Future<String?> getEmail() => _storage.read(key: _emailKey);

  static Future<String?> getRole() => _storage.read(key: _roleKey);

  static Future<String?> getNotificationAccountScope() async =>
      (await getEmail()) ?? (await getToken());

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
      ApiConfig.apiUri('user'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
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
      ApiConfig.apiUri('change-password'),
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

  static Future<void> requestPasswordReset(String email) async {
    late final http.Response response;
    try {
      response = await http
          .post(
            ApiConfig.apiUri('password/forgot'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const AuthException(
        'The request timed out. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const AuthException(
        'Cannot connect to the server. Check your connection and try again.',
      );
    }

    if (response.statusCode == 429) {
      throw const AuthException('Too many attempts. Please try again later.');
    }
    if (response.statusCode != 200) {
      throw const AuthException(
        'Unable to send the request. Please try again later.',
      );
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _emailKey);
  }
}
