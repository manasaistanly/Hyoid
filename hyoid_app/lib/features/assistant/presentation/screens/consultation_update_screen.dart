import 'package:flutter/material.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/assistant/data/services/assistant_api_service.dart';

class ConsultationUpdateScreen extends StatefulWidget {
  final String consultationId;
  final String patientName;
  final String initialSymptoms;

  const ConsultationUpdateScreen({
    super.key,
    required this.consultationId,
    required this.patientName,
    required this.initialSymptoms,
  });

  @override
  State<ConsultationUpdateScreen> createState() => _ConsultationUpdateScreenState();
}

class _ConsultationUpdateScreenState extends State<ConsultationUpdateScreen> {
  final AssistantApiService _apiService = AssistantApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _symptomsController;
  late TextEditingController _bpController;
  late TextEditingController _sugarController;
  late TextEditingController _notesController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _symptomsController = TextEditingController(text: widget.initialSymptoms);
    _bpController = TextEditingController();
    _sugarController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _bpController.dispose();
    _sugarController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _apiService.submitConsultation(
        consultationId: widget.consultationId,
        symptoms: _symptomsController.text,
        vitals: {
          'bp': _bpController.text,
          'sugar': _sugarController.text,
        },
        notes: _notesController.text,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission successful'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Submission failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        title: Text('Update: ${widget.patientName}', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.darkSurface,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Patient Vitals'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Blood Pressure',
                      controller: _bpController,
                      hint: 'e.g. 120/80',
                      icon: Icons.monitor_heart_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'Sugar Level',
                      controller: _sugarController,
                      hint: 'e.g. 140 mg/dL',
                      icon: Icons.water_drop_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Clinical Details'),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Symptoms',
                controller: _symptomsController,
                hint: 'Update patient symptoms...',
                maxLines: 3,
                validator: (value) => (value == null || value.isEmpty) ? 'Symptoms are required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Assistant Notes',
                controller: _notesController,
                hint: 'Add any additional notes for the doctor...',
                maxLines: 4,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.orangeAccent,
                    disabledBackgroundColor: Colors.white10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit to Doctor',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: AppTheme.orangeAccent, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            prefixIcon: icon != null ? Icon(icon, color: Colors.white38, size: 20) : null,
            filled: true,
            fillColor: AppTheme.darkSurface,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.orangeAccent)),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
