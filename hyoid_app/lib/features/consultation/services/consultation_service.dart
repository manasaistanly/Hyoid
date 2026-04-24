import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../models/consultation_model.dart';
import '../models/prescription_model.dart';

class ConsultationService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Update with your server URL

  // Doctors
  static Future<List<Doctor>> getDoctors({String? specialization, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (specialization != null) queryParams['specialization'] = specialization;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/doctors').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      throw Exception('Error fetching doctors: $e');
    }
  }

  static Future<Doctor> getDoctorById(String doctorId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/doctors/$doctorId'));

      if (response.statusCode == 200) {
        return Doctor.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load doctor');
      }
    } catch (e) {
      throw Exception('Error fetching doctor: $e');
    }
  }

  // Appointments
  static Future<Appointment> createAppointment({
    required String doctorId,
    required String patientId,
    required DateTime scheduledAt,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appointments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'doctorId': doctorId,
          'patientId': patientId,
          'scheduledAt': scheduledAt.toIso8601String(),
          'type': type,
        }),
      );

      if (response.statusCode == 201) {
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create appointment');
      }
    } catch (e) {
      throw Exception('Error creating appointment: $e');
    }
  }

  static Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/appointments/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      throw Exception('Error fetching appointments: $e');
    }
  }

  // Consultations
  static Future<Consultation> startConsultation({
    required String appointmentId,
    required String doctorId,
    required String patientId,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/consultations/start'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'appointmentId': appointmentId,
          'doctorId': doctorId,
          'patientId': patientId,
          'type': type,
        }),
      );

      if (response.statusCode == 201) {
        return Consultation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to start consultation');
      }
    } catch (e) {
      throw Exception('Error starting consultation: $e');
    }
  }

  static Future<void> endConsultation(String consultationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/consultations/end'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'consultationId': consultationId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to end consultation');
      }
    } catch (e) {
      throw Exception('Error ending consultation: $e');
    }
  }

  // Prescriptions
  static Future<Prescription> createPrescription({
    required String consultationId,
    required String doctorId,
    required String patientId,
    required String diagnosis,
    required List<PrescriptionItem> medicines,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/prescriptions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'consultationId': consultationId,
          'doctorId': doctorId,
          'patientId': patientId,
          'diagnosis': diagnosis,
          'medicines': medicines.map((item) => item.toJson()).toList(),
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        return Prescription.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create prescription');
      }
    } catch (e) {
      throw Exception('Error creating prescription: $e');
    }
  }

  static Future<List<Prescription>> getUserPrescriptions(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/prescriptions/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Prescription.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load prescriptions');
      }
    } catch (e) {
      throw Exception('Error fetching prescriptions: $e');
    }
  }
}