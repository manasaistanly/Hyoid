import 'package:flutter/material.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart' show kDoctorBlue;
import 'package:hyoid_app/features/doctor/data/services/doctor_api_service.dart';
import 'package:hyoid_app/features/doctor/data/models/prescription.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';

class PrescriptionScreen extends StatefulWidget {
  final String? consultationId;
  const PrescriptionScreen({super.key, this.consultationId});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final DoctorApiService _apiService = DoctorApiService();
  final List<Map<String, String>> _medicines = [];
  final TextEditingController _notesController = TextEditingController();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  bool _isSubmitting = false;

  void _addMedicine() {
    if (_nameController.text.isEmpty) return;
    setState(() {
      _medicines.add({
        'name': _nameController.text,
        'dosage': _dosageController.text,
        'duration': _durationController.text,
      });
      _nameController.clear();
      _dosageController.clear();
      _durationController.clear();
    });
  }

  void _removeMedicine(int index) {
    setState(() => _medicines.removeAt(index));
  }

  Future<void> _submit() async {
    if (widget.consultationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: No consultation selected')));
      return;
    }
    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one medicine')));
      return;
    }

    setState(() => _isSubmitting = true);
    
    // Convert mock format to model format
    final medicinesList = _medicines.map((m) => Medicine(
      name: m['name']!,
      dosage: m['dosage']!,
      duration: m['duration']!,
    )).toList();

    final prescription = Prescription(
      medicines: medicinesList,
      notes: _notesController.text,
    );

    final success = await _apiService.submitPrescription(widget.consultationId!, prescription);
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prescription submitted successfully')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit prescription')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151515),
        title: const Text('New Prescription'),
        actions: [
          if (_isSubmitting)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator(color: kDoctorBlue)))
          else
            TextButton(
              onPressed: _submit,
              child: const Text('SUBMIT', style: TextStyle(color: kDoctorBlue, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Medicine', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildMedicineForm(),
            const SizedBox(height: 32),
            const Text('Medicines List', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_medicines.isEmpty)
              _buildEmptyMedicines()
            else
              _buildMedicinesList(),
            const SizedBox(height: 32),
            const Text('Additional Notes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                hintText: 'Any specific instructions for the patient...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildField('Medicine Name', _nameController, Icons.medication_rounded),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildField('Dosage (e.g. 1-0-1)', _dosageController, Icons.timer_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _buildField('Duration', _durationController, Icons.calendar_today_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addMedicine,
            style: ElevatedButton.styleFrom(
              backgroundColor: kDoctorBlue,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add to List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white24, size: 20),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
        filled: true,
        fillColor: Colors.black26,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildEmptyMedicines() {
    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: const Text('No medicines added yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white24)),
    );
  }

  Widget _buildMedicinesList() {
    return Column(
      children: _medicines.asMap().entries.map((entry) {
        final idx = entry.key;
        final med = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kDoctorBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kDoctorBlue.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: kDoctorBlue, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${med['dosage']} · ${med['duration']}', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeMedicine(idx),
                icon: const Icon(Icons.remove_circle_outline_rounded, color: AppTheme.dangerRed, size: 22),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
