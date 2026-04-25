import 'package:flutter/material.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart' show kDoctorBlue;
import 'package:hyoid_app/features/doctor/data/services/doctor_api_service.dart';
import 'package:hyoid_app/features/doctor/data/models/patient.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/doctor/dashboard/prescription_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String consultationId;
  const PatientDetailsScreen({super.key, required this.consultationId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final DoctorApiService _apiService = DoctorApiService();
  late Future<Patient> _patientFuture;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _patientFuture = _apiService.getPatientDetails(widget.consultationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Patient Details'),
      ),
      body: FutureBuilder<Patient>(
        future: _patientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kDoctorBlue));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          final patient = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientHeader(patient),
                const SizedBox(height: 32),
                _buildSection('Symptoms', patient.symptoms ?? 'Not specified'),
                const SizedBox(height: 24),
                _buildVitalsCard(patient.vitals),
                const SizedBox(height: 24),
                _buildSection('Assistant Notes', patient.assistantNotes ?? 'No notes provided.'),
                const SizedBox(height: 32),
                if (patient.images != null && patient.images!.isNotEmpty) ...[
                  const Text('Clinical Images', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildImageGallery(patient.images!),
                  const SizedBox(height: 32),
                ],
                _buildActionButtons(patient),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatientHeader(Patient patient) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: Color(0xFF1A1A1A),
          child: Icon(Icons.person_rounded, size: 40, color: kDoctorBlue),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patient.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Age: ${patient.age} · Male', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Text(content, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildVitalsCard(Map<String, dynamic>? vitals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vitals', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _vitalItem('BP', vitals?['bp'] ?? 'N/A', Icons.favorite_rounded, Colors.redAccent),
            const SizedBox(width: 12),
            _vitalItem('Sugar', vitals?['sugar'] ?? 'N/A', Icons.water_drop_rounded, Colors.blueAccent),
            const SizedBox(width: 12),
            _vitalItem('Temp', vitals?['temperature'] ?? 'N/A', Icons.thermostat_rounded, Colors.orangeAccent),
          ],
        ),
      ],
    );
  }

  Widget _vitalItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(Patient patient) {
    if (_isActionLoading) {
      return const Center(child: CircularProgressIndicator(color: kDoctorBlue));
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionButton(
                'Reject', 
                AppTheme.dangerRed, 
                Icons.close_rounded,
                () => _performAction(() => _apiService.rejectRequest(widget.consultationId)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                'Accept', 
                kDoctorBlue, 
                Icons.check_rounded,
                () => _performAction(() => _apiService.acceptRequest(widget.consultationId)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _actionButton(
          'Issue Prescription', 
          AppTheme.successGreen, 
          Icons.medication_rounded,
          () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => PrescriptionScreen(consultationId: widget.consultationId))
          ),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _actionButton(String label, Color color, IconData icon, VoidCallback onTap, {bool isFullWidth = false}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        minimumSize: Size(isFullWidth ? double.infinity : 0, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        elevation: 0,
      ),
    );
  }

  void _performAction(Future<bool> Function() action) async {
    setState(() => _isActionLoading = true);
    final success = await action();
    if (mounted) {
      setState(() => _isActionLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action successful')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action failed. Please try again.')));
      }
    }
  }
}
