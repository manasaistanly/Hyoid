import 'package:dio/dio.dart';
import 'package:hyoid_app/core/constants/api_constants.dart';
import 'package:hyoid_app/features/doctor/data/models/doctor_request.dart';
import 'package:hyoid_app/features/doctor/data/models/patient.dart';
import 'package:hyoid_app/features/doctor/data/models/prescription.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "${ApiConstants.baseUrl}/doctor",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  DoctorApiService() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('jwt_token');
          // Note: App should handle redirection to login based on token removal
        }
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await dio.get('/stats');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      throw Exception('Failed to load stats');
    } catch (e) {
      return {
        'totalToday': 0,
        'pending': 0,
        'emergency': 0,
        'completed': 0,
        'nextCase': null,
      };
    }
  }

  Future<List<DoctorRequest>> getRequests({String? status}) async {
    try {
      final response = await dio.get('/requests', queryParameters: status != null ? {'status': status} : null);
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => DoctorRequest.fromJson(json)).toList();
      }
      throw Exception('Failed to load requests');
    } catch (e) {
      // Fallback to empty list instead of mock data for production safety
      return [];
    }
  }

  Future<List<DoctorRequest>> getHistory() async {
    try {
      final response = await dio.get('/history');
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => DoctorRequest.fromJson(json)).toList();
      }
      throw Exception('Failed to load history');
    } catch (e) {
      return [];
    }
  }

  Future<Patient> getPatientDetails(String id) async {
    try {
      final response = await dio.get('/patient/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Patient.fromJson(data);
      }
      throw Exception('Failed to load patient details');
    } catch (e) {
      return Patient(id: id, name: 'Unknown Patient', age: 0);
    }
  }

  Future<bool> acceptRequest(String id) async {
    try {
      final response = await dio.post('/accept', data: {'id': id});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectRequest(String id) async {
    try {
      final response = await dio.post('/reject', data: {'id': id});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitPrescription(String id, Prescription prescription) async {
    try {
      final response = await dio.post(
        '/prescription',
        data: {
          'id': id,
          'prescription': prescription.toJson(),
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> suggestLab(String id, List<String> labTests) async {
    try {
      final response = await dio.post(
        '/lab',
        data: {'id': id, 'labTests': labTests},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> suggestHospital(String id, Map<String, dynamic> referral) async {
    try {
      final response = await dio.post(
        '/hospital',
        data: {'id': id, 'hospitalReferral': referral},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dio.get('/profile');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      throw Exception('Failed to load profile');
    } catch (e) {
      return {};
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await dio.put('/profile', data: profileData);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
