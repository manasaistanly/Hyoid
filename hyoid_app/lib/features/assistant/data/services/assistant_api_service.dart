import 'package:dio/dio.dart';
import 'package:hyoid_app/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyoid_app/features/assistant/data/models/assistant_consultation.dart';

class AssistantApiService {
  final Dio _dio = Dio();

  AssistantApiService() {
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
      onError: (e, handler) {
        print('API Error: ${e.response?.data}');
        return handler.next(e);
      },
    ));
  }

  Future<List<AssistantConsultation>> getRequests() async {
    try {
      final response = await _dio.get('/assistant/requests');
      if (response.data['success'] == true) {
        final List<dynamic> list = response.data['data'];
        return list.map((e) => AssistantConsultation.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> submitConsultation({
    required String consultationId,
    required String symptoms,
    required Map<String, String> vitals,
    required String notes,
  }) async {
    try {
      final response = await _dio.post('/assistant/submit', data: {
        'consultationId': consultationId,
        'symptoms': symptoms,
        'vitals': vitals,
        'notes': notes,
      });
      return response.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
