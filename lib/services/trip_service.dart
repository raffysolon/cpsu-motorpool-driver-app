import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class TripService {
  static Future<http.Response> getTripTicket(int tripId) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http
        .get(
          Uri.parse('${AuthService.baseUrl}/trips/$tripId/print'),
          headers: {
            'Accept': 'application/pdf',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('PDF request failed (${response.statusCode})');
    }
    if (response.bodyBytes.isEmpty) {
      throw Exception('The trip ticket PDF is empty');
    }
    if (response.bodyBytes.length < 4 ||
        String.fromCharCodes(response.bodyBytes.take(4)) != '%PDF') {
      throw Exception('The server returned an invalid PDF');
    }

    return response;
  }

  static Future<Map<String, dynamic>?> getMyAssignment() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/my-assignment'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Unable to load vehicle assignment');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getMyTrips({String? status}) async {
    final query = status == null || status.isEmpty ? '' : '?status=$status';
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/my-trips$query'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load trips');
    }

    final data = jsonDecode(response.body);
    return (data is List ? data : const [])
        .whereType<Map>()
        .map((trip) => Map<String, dynamic>.from(trip))
        .toList();
  }

  static Future<Map<String, dynamic>> _movementAction(String path) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}$path'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Trip action failed (${response.statusCode})');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> startTrip(int tripId) =>
      _movementAction('/trips/$tripId/start');

  static Future<Map<String, dynamic>> endTrip(int tripId) =>
      _movementAction('/trips/$tripId/end');

  static Future<Map<String, dynamic>> startReturnTrip(int tripId) =>
      _movementAction('/trips/$tripId/start-return');

  static Future<Map<String, dynamic>> endReturnTrip(int tripId) =>
      _movementAction('/trips/$tripId/end-return');

  static Future<Map<String, dynamic>> createTrip({
    required String origin,
    required String destination,
    required String purpose,
    required DateTime scheduledDeparture,
    DateTime? returnScheduledDeparture,
    required List<dynamic> passengers,
  }) async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/trips'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'origin': origin,
        'destination': destination,
        'purpose': purpose,
        'scheduled_departure': scheduledDeparture.toIso8601String(),
        'return_scheduled_departure': returnScheduledDeparture
            ?.toIso8601String(),
        'passengers': passengers.map((passenger) {
          if (passenger is String) {
            return {'name': passenger, 'designation': null};
          }
          return passenger;
        }).toList(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Unable to create trip ticket');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
