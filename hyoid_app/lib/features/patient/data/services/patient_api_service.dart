import 'package:dio/dio.dart';
import 'package:hyoid_app/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientApiService {
  final Dio _dio = Dio();

  PatientApiService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return response.data['data'] ?? {};
    } catch (e) {
      return {};
    }
  }

  Future<List<dynamic>> getServices() async {
    try {
      final response = await _dio.get('/services');
      return response.data['data'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getLabs() async {
    try {
      final response = await _dio.get('/labs');
      return response.data['data'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createRequest(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/bookings/create', data: data);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
