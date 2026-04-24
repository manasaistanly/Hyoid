import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import '../models/consultation_model.dart';
import '../models/doctor_model.dart';
import '../models/prescription_model.dart';

class PrescriptionScreen extends StatefulWidget {
  final Consultation consultation;
  final Doctor doctor;

  const PrescriptionScreen({
    super.key,
    required this.consultation,
    required this.doctor,
  });

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  Prescription? _prescription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrescription();
  }

  Future<void> _loadPrescription() async {
    try {
      // For demo purposes, we'll create a mock prescription
      // In real app, this would be fetched from the server
      await Future.delayed(const Duration(seconds: 2)); // Simulate loading

      final mockPrescription = Prescription(
        id: 'prescription_${widget.consultation.id}',
        consultationId: widget.consultation.id,
        doctorId: widget.doctor.id,
        patientId: widget.consultation.patientId,
        issuedAt: DateTime.now(),
        diagnosis: 'Common Cold with mild fever',
        medicines: [
          PrescriptionItem(
            medicineName: 'Paracetamol 500mg',
            dosage: '1 tablet',
            frequency: 'Every 6 hours',
            duration: 5,
            instructions: 'Take with food. Do not exceed 4 tablets in 24 hours.',
            genericAlternative: 'Acetaminophen',
          ),
          PrescriptionItem(
            medicineName: 'Cetirizine 10mg',
            dosage: '1 tablet',
            frequency: 'Once daily',
            duration: 7,
            instructions: 'Take in the evening. May cause drowsiness.',
          ),
          PrescriptionItem(
            medicineName: 'Steam Inhalation',
            dosage: 'As needed',
            frequency: '2-3 times daily',
            duration: 5,
            instructions: 'Use warm water with menthol. Breathe deeply for 10 minutes.',
          ),
        ],
        notes: 'Rest well, stay hydrated, and monitor temperature. Follow up if symptoms worsen.',
        doctorSignature: 'Dr. ${widget.doctor.name}',
        isDigital: true,
      );

      setState(() {
        _prescription = mockPrescription;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load prescription: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.pureBlack,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.darkSurface,
          title: const Text('Prescription', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.orangeAccent)),
      );
    }

    if (_prescription == null) {
      return Scaffold(
        backgroundColor: AppTheme.pureBlack,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.darkSurface,
          title: const Text('Prescription', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text('Prescription not available', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Prescription', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _downloadPrescription,
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _sharePrescription,
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E2E2E), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(widget.doctor.profileImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: widget.doctor.profileImage.isEmpty
                            ? Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.orangeAccent,
                                ),
                                child: const Icon(Icons.person, color: Colors.white, size: 25),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. ${widget.doctor.name}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              widget.doctor.specialization,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'DIGITAL',
                          style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF2E2E2E)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Date Issued',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        _formatDate(_prescription!.issuedAt),
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Diagnosis
            const Text(
              'Diagnosis',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
              ),
              child: Text(
                _prescription!.diagnosis,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              ),
            ),

            const SizedBox(height: 24),

            // Medicines
            const Text(
              'Prescribed Medicines',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ..._prescription!.medicines.map((medicine) => MedicineCard(medicine: medicine)),

            const SizedBox(height: 24),

            // Notes
            if (_prescription!.notes != null && _prescription!.notes!.isNotEmpty) ...[
              const Text(
                'Additional Notes',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E2E2E), width: 1),
                ),
                child: Text(
                  _prescription!.notes!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Doctor Signature
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E2E2E), width: 1.5),
              ),
              child: Column(
                children: [
                  const Text(
                    'Doctor\'s Signature',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _prescription!.doctorSignature,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    width: 100,
                    color: AppTheme.orangeAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _downloadPrescription,
                    icon: const Icon(Icons.download, color: AppTheme.orangeAccent),
                    label: const Text('Download PDF'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.orangeAccent, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sharePrescription,
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _downloadPrescription() {
    // TODO: Implement PDF download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF download feature coming soon!')),
    );
  }

  void _sharePrescription() {
    // TODO: Implement sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class MedicineCard extends StatelessWidget {
  final PrescriptionItem medicine;

  const MedicineCard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2E2E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication, color: AppTheme.orangeAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  medicine.medicineName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip('Dosage', medicine.dosage),
              const SizedBox(width: 8),
              _buildInfoChip('Frequency', medicine.frequency),
              const SizedBox(width: 8),
              _buildInfoChip('Duration', '${medicine.duration} days'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Instructions: ${medicine.instructions}',
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          if (medicine.genericAlternative != null) ...[
            const SizedBox(height: 8),
            Text(
              'Generic Alternative: ${medicine.genericAlternative}',
              style: const TextStyle(color: AppTheme.orangeAccent, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2E2E2E), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}