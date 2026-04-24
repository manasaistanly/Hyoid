import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final Dio _dio = DioClient().dio;

  Future<AppointmentModel> createAppointment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.createAppointment, data: data);
      return AppointmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<List<AppointmentModel>> getMyAppointments() async {
    try {
      final response = await _dio.get(ApiConstants.getMyAppointments);
      final list = response.data['data'] as List;
      return list.map((json) => AppointmentModel.fromJson(json)).toList();
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.getAppointmentById}$id');
      return AppointmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      await _dio.delete('${ApiConstants.cancelAppointment}$id');
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<List<AppointmentModel>> getAllAppointments() async {
    try {
      final response = await _dio.get(ApiConstants.getAllAppointments);
      final list = response.data['data'] as List;
      return list.map((json) => AppointmentModel.fromJson(json)).toList();
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<AppointmentModel> updateAppointment(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('${ApiConstants.updateAppointment}$id', data: data);
      return AppointmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<List<AppointmentModel>> getAssignedAppointments() async {
    try {
      final response = await _dio.get(ApiConstants.getAssignedAppointments);
      final list = response.data['data'] as List;
      return list.map((json) => AppointmentModel.fromJson(json)).toList();
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<AppointmentModel> respondToAppointment(String id, String status, String notes) async {
    try {
      final response = await _dio.put('${ApiConstants.respondToAppointment}$id/respond', data: {
        'status': status,
        'staffNotes': notes
      });
      return AppointmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }
}
