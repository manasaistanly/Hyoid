import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import 'appointment_service.dart';
import 'user_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Global provider instance to follow the existing app style without pubspec changes
  static final AppointmentProvider instance = AppointmentProvider();

  Future<void> loadUserAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await UserService.loadProfile();
      if (user.userId.isNotEmpty) {
        final service = AppointmentService();
        final data = await service.getMyAppointments();
        _appointments = data;
      } else {
        // Fallback for mocked/unauthenticated states
        _appointments = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppointmentModel?> submitAppointment(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await UserService.loadProfile();
      if (user.userId.isNotEmpty) {
        data['user_id'] = user.userId;
      }

      final service = AppointmentService();
      final newAppointment = await service.createAppointment(data);
      _appointments.insert(0, newAppointment); // Add to top of list
      return newAppointment;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
