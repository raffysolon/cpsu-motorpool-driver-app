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

  static Future<List<Map<String, dynamic>>> getMyTrips({
    String? status,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse('${AuthService.baseUrl}/my-trips')
        .replace(queryParameters: queryParams);
    
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      // Handle specific error codes
      if (response.statusCode == 401) {
        throw Exception('Your session has expired. Please log in again.');
      }
      if (response.statusCode == 403) {
        throw Exception('You do not have permission to access trips.');
      }
      if (response.statusCode == 429) {
        throw Exception('Too many requests. Please wait a moment and try again.');
      }
      throw Exception('Unable to load trips');
    }

    final data = jsonDecode(response.body);
    
    // Handle paginated response
    final records = data is Map && data['data'] is List
        ? data['data'] as List
        : data is List
        ? data
        : const [];
    
    return records
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
      // Handle specific error codes
      if (response.statusCode == 401) {
        throw Exception('Your session has expired. Please log in again.');
      }
      if (response.statusCode == 403) {
        throw Exception('You do not have permission to create trips.');
      }
      if (response.statusCode == 422) {
        // Validation error - could be active trip conflict
        final error = jsonDecode(response.body);
        if (error is Map && error['message'] != null) {
          throw ActiveTripException(
            error['message'].toString(),
            error['existing_trip'],
          );
        }
        throw Exception('Unable to create trip ticket: Validation failed');
      }
      if (response.statusCode == 429) {
        throw Exception('Too many requests. Please wait a moment and try again.');
      }
      throw Exception('Unable to create trip ticket');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

// Custom exception for active trip validation error
class ActiveTripException implements Exception {
  final String message;
  final Map<String, dynamic>? existingTrip;
  
  ActiveTripException(this.message, this.existingTrip);
  
  @override
  String toString() => message;
}
