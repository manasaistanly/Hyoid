import 'package:dio/dio.dart';
import 'package:hyoid_app/core/constants/api_constants.dart';
import 'package:hyoid_app/features/doctor/data/models/doctor_request.dart';
import 'package:hyoid_app/features/doctor/data/models/patient.dart';
import 'package:hyoid_app/features/doctor/data/models/prescription.dart';

class DoctorApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "${ApiConstants.baseUrl}/doctor",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'doctor_default_token', // Mock token
      },
    ),
  );

  Future<List<DoctorRequest>> getRequests() async {
    try {
      final response = await dio.get('/requests');
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => DoctorRequest.fromJson(json)).toList();
      }
      throw Exception('Failed to load requests');
    } on DioException catch (e) {
      // Fallback to mock data if server is not running
      return _getMockRequests();
    } catch (e) {
      throw Exception('Unexpected error: $e');
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
    } on DioException catch (e) {
      return Patient(id: id, name: 'Offline Patient', age: 0);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> submitPrescription(Prescription prescription) async {
    try {
      final response = await dio.post(
        '/prescription',
        data: prescription.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> suggestLab(String patientId, String testName) async {
    try {
      final response = await dio.post(
        '/lab',
        data: {'patientId': patientId, 'testName': testName},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> suggestHospital(String patientId, String reason) async {
    try {
      final response = await dio.post(
        '/hospital',
        data: {'patientId': patientId, 'reason': reason},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  List<DoctorRequest> _getMockRequests() {
    return [
      DoctorRequest(
        id: '1',
        patientId: 'p_001',
        patientName: 'Ravi (Offline)',
        age: 45,
        symptoms: 'Fever, cough',
        priority: RequestPriority.normal,
        status: RequestStatus.pending,
        time: DateTime.now(),
      ),
    ];
  }
}
