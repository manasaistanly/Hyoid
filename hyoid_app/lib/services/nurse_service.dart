import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nurse_model.dart';
import '../models/nurse_booking_model.dart';
import 'user_service.dart';

class NurseService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await UserService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Nurse>> getNurses({
    String? service,
    int? experience,
    double? rating,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      'service': ?service,
      if (experience != null) 'experience': experience.toString(),
      if (rating != null) 'rating': rating.toString(),
      'sort': ?sort,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri.parse(
      '$baseUrl/nurses',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['nurses'] as List)
          .map((json) => Nurse.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load nurses');
    }
  }

  static Future<Nurse> getNurseById(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/nurses/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Nurse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load nurse');
    }
  }

  static Future<NurseBooking> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/nurse-bookings'),
      headers: headers,
      body: json.encode(bookingData),
    );

    if (response.statusCode == 201) {
      return NurseBooking.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create booking');
    }
  }

  static Future<List<NurseBooking>> getUserBookings() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/nurse-bookings/user/bookings'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List).map((json) => NurseBooking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }
}
