import 'package:flutter/material.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart'
    show kDoctorBlue;
import 'package:hyoid_app/theme/app_theme.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;
  const PatientDetailScreen({super.key, required this.appointment});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final TextEditingController _notesCtrl = TextEditingController();
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = (widget.appointment['notes'] as String?) ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveNotes() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _saving = false;
      _saved = true;
    });
    widget.appointment['notes'] = _notesCtrl.text;
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Patient Details',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                kDoctorBlue.withValues(alpha: 0.5),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Patient Header ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: kDoctorBlue.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: kDoctorBlue.withValues(alpha: 0.15),
                    child: Text(
                      (a['patientName'] as String)[0],
                      style: const TextStyle(
                          color: kDoctorBlue,
                          fontWeight: FontWeight.w800,
                          fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['patientName'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Age ${a['patientAge']}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Appointment Info ──────────────────────────────────
            _sectionLabel('Appointment Info'),
            const SizedBox(height: 12),
            _infoRow(Icons.calendar_today_rounded, 'Date & Time',
                '${a['date']} at ${a['time']}'),
            _infoRow(
                a['type'] == 'online'
                    ? Icons.videocam_rounded
                    : Icons.location_on_rounded,
                'Visit Type',
                (a['type'] as String).toUpperCase()),
            _infoRow(Icons.timer_rounded, 'Duration', '${a['duration']} min'),
            _infoRow(Icons.chat_bubble_outline_rounded, 'Reason',
                a['reason'] as String),

            const SizedBox(height: 24),

            // ── Past Appointments ─────────────────────────────────
            _sectionLabel('Past Appointments with Patient'),
            const SizedBox(height: 12),
            _buildPastAppointment('Apr 3, 2026', 'ECG Review', 'completed'),
            _buildPastAppointment('Mar 17, 2026', 'Routine Checkup', 'completed'),
            _buildPastAppointment('Feb 22, 2026', 'Hypertension Follow-up', 'completed'),

            const SizedBox(height: 24),

            // ── Consultation Notes ────────────────────────────────
            _sectionLabel('Consultation Notes'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: const Color(0xFF333333), width: 1.5),
              ),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 6,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                      'Add consultation notes, prescriptions, observations...',
                  hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveNotes,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Icon(
                        _saved
                            ? Icons.check_rounded
                            : Icons.save_rounded,
                        color: Colors.white,
                      ),
                label: Text(
                    _saved
                        ? 'Saved!'
                        : _saving
                            ? 'Saving...'
                            : 'Save Notes',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _saved ? AppTheme.successGreen : kDoctorBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Row(
        children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(
                color: kDoctorBlue,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
        ],
      );

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kDoctorBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kDoctorBlue, size: 16),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastAppointment(
      String date, String reason, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF2A2A2A), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reason,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 3),
                Text(date,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status,
                style: const TextStyle(
                    color: AppTheme.successGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
