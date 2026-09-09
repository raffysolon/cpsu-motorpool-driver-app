import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/notifications'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load notifications');
    }

    final data = jsonDecode(response.body);
    return (data is List ? data : const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<void> markAsRead(int id) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) return;

    await http.put(
      Uri.parse('${AuthService.baseUrl}/notifications/$id/read'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
  }

  static Future<int> getUnreadCount() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/notifications/unread-count'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load unread notification count');
    }

    final data = jsonDecode(response.body);
    return data is Map ? (data['count'] as num?)?.toInt() ?? 0 : 0;
  }

  static Future<void> markTripNotificationsAsRead(String tripId) async {
    final notifications = await getNotifications();
    final matchingNotifications = notifications.where((notification) {
      final notificationTripId = notification['trip_id']?.toString();
      return notificationTripId == tripId && notification['is_read'] != true;
    });

    await Future.wait(
      matchingNotifications.map((notification) {
        final id = int.tryParse(notification['id'].toString());
        return id == null ? Future<void>.value() : markAsRead(id);
      }),
    );
  }
}
