import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../core/errors/failures.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/constants/api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _service = AppointmentService();
  IO.Socket? _socket;
  
  List<AppointmentModel> _appointments = [];
  AppointmentModel? _currentAppointment;
  bool _isLoading = false;
  Failure? _error;

  List<AppointmentModel> get appointments => _appointments;
  AppointmentModel? get currentAppointment => _currentAppointment;
  bool get isLoading => _isLoading;
  Failure? get error => _error;

  Future<void> fetchMyAppointments() async {
    _setLoading(true);
    try {
      _appointments = await _service.getMyAppointments();
      _setLoading(false);
    } catch (e) {
      _error = e is Failure ? e : UnknownFailure(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> bookAppointment(AppointmentModel appointmentData) async {
    _setLoading(true);
    try {
      final newAppt = await _service.createAppointment(appointmentData.toJson());
      _appointments.insert(0, newAppt);
      _currentAppointment = newAppt;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e is Failure ? e : UnknownFailure(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void setCurrentAppointment(AppointmentModel appointment) {
    _currentAppointment = appointment;
    notifyListeners();
  }

  // Socket IO setup for Realtime
  Future<void> initSocket(String userId) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');

    _socket = IO.io(ApiConstants.baseUrl.replaceAll('/api', ''), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'Authorization': 'Bearer $token'}
    });

    _socket?.connect();
    
    _socket?.onConnect((_) {
      _socket?.emit('join', 'user:$userId');
    });

    _socket?.on('appointment:updated', (data) {
      if (data['appointmentId'] != null) {
        _updateAppointmentStateRealtime(data['appointmentId']);
      }
    });
  }

  Future<void> _updateAppointmentStateRealtime(String appointmentId) async {
    try {
      final updatedAppt = await _service.getAppointmentById(appointmentId);
      final index = _appointments.indexWhere((app) => app.id == appointmentId);
      if (index != -1) {
        _appointments[index] = updatedAppt;
      }
      if (_currentAppointment?.id == appointmentId) {
        _currentAppointment = updatedAppt;
      }
      notifyListeners();
    } catch (e) {
      // Background failure
    }
  }

  void disposeSocket() {
    _socket?.disconnect();
    _socket?.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }
}
