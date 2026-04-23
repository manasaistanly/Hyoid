import 'package:flutter/material.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart'
    show kDoctorBlue;
import 'package:hyoid_app/features/doctor/appointments/patient_detail_screen.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data (mirrors GET /api/doctor/appointments)
  final List<Map<String, dynamic>> _appointments = [
    {'id': 'appt_001', 'patientName': 'Arjun Sharma', 'patientAge': 34, 'date': 'Today', 'time': '11:30 AM', 'duration': 30, 'type': 'in-person', 'status': 'confirmed', 'reason': 'Chest pain follow-up', 'notes': ''},
    {'id': 'appt_002', 'patientName': 'Priya Menon', 'patientAge': 28, 'date': 'Today', 'time': '02:00 PM', 'duration': 30, 'type': 'online', 'status': 'pending', 'reason': 'Routine checkup', 'notes': ''},
    {'id': 'appt_003', 'patientName': 'Rahul Dev', 'patientAge': 45, 'date': 'Today', 'time': '04:30 PM', 'duration': 45, 'type': 'in-person', 'status': 'pending', 'reason': 'Hypertension management', 'notes': ''},
    {'id': 'appt_004', 'patientName': 'Kavya Nair', 'patientAge': 31, 'date': 'Apr 18', 'time': '10:00 AM', 'duration': 30, 'type': 'online', 'status': 'confirmed', 'reason': 'Cardiology consultation', 'notes': ''},
    {'id': 'appt_005', 'patientName': 'Mohan Raj', 'patientAge': 60, 'date': 'Apr 19', 'time': '09:30 AM', 'duration': 30, 'type': 'in-person', 'status': 'confirmed', 'reason': 'Follow-up ECG', 'notes': ''},
    {'id': 'appt_006', 'patientName': 'Suresh Kumar', 'patientAge': 52, 'date': 'Apr 16', 'time': '09:00 AM', 'duration': 30, 'type': 'in-person', 'status': 'completed', 'reason': 'ECG review', 'notes': 'Prescribed Metoprolol 25mg.'},
    {'id': 'appt_007', 'patientName': 'Ananya Singh', 'patientAge': 22, 'date': 'Apr 15', 'time': '03:00 PM', 'duration': 30, 'type': 'online', 'status': 'cancelled', 'reason': 'Palpitations', 'notes': ''},
  ];

  List<Map<String, dynamic>> _getFiltered(String tab) {
    if (tab == 'Today') {
      return _appointments
          .where((a) =>
              a['date'] == 'Today' &&
              a['status'] != 'cancelled')
          .toList();
    } else if (tab == 'Upcoming') {
      return _appointments
          .where((a) =>
              a['date'] != 'Today' &&
              (a['status'] == 'confirmed' || a['status'] == 'pending'))
          .toList();
    } else if (tab == 'Past') {
      return _appointments
          .where((a) => a['status'] == 'completed')
          .toList();
    } else {
      return _appointments
          .where((a) => a['status'] == 'cancelled')
          .toList();
    }
  }

  void _updateStatus(String id, String newStatus) {
    setState(() {
      final appt = _appointments.firstWhere((a) => a['id'] == id);
      appt['status'] = newStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Appointments',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kDoctorBlue,
          indicatorWeight: 3,
          labelColor: kDoctorBlue,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ['Today', 'Upcoming', 'Past', 'Cancelled'].map((tab) {
          final list = _getFiltered(tab);
          if (list.isEmpty) {
            return _buildEmpty(tab);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            itemCount: list.length,
            itemBuilder: (_, i) => _AppointmentCard(
              appointment: list[i],
              onStatusChange: _updateStatus,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty(String tab) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded,
              color: Colors.white24, size: 56),
          const SizedBox(height: 16),
          Text('No $tab appointments',
              style: const TextStyle(color: Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }
}

// ── Appointment Card ──────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final void Function(String id, String status) onStatusChange;

  const _AppointmentCard({
    required this.appointment,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final status = a['status'] as String;
    final statusColors = {
      'confirmed': AppTheme.successGreen,
      'pending': AppTheme.warningOrange,
      'completed': kDoctorBlue,
      'cancelled': AppTheme.dangerRed,
      'no_show': Colors.white38,
    };
    final color = statusColors[status] ?? Colors.white38;
    final isOnline = a['type'] == 'online';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: kDoctorBlue.withValues(alpha: 0.12),
                child: Text(
                  (a['patientName'] as String)[0],
                  style: const TextStyle(
                      color: kDoctorBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['patientName'] as String,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    const SizedBox(height: 3),
                    Text('Age ${a['patientAge']} · ${a['reason']}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date / time / type row
          Row(
            children: [
              _infoChip(Icons.calendar_today_rounded,
                  '${a['date']} · ${a['time']}', Colors.white54),
              const SizedBox(width: 10),
              _infoChip(
                isOnline ? Icons.videocam_rounded : Icons.location_on_rounded,
                isOnline ? 'Online' : 'In-Person',
                isOnline ? kDoctorBlue : AppTheme.warningOrange,
              ),
              const SizedBox(width: 10),
              _infoChip(Icons.timer_rounded, '${a['duration']} min',
                  Colors.white38),
            ],
          ),
          // Action buttons
          if (status == 'pending' || status == 'confirmed') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (status == 'pending')
                  _actionBtn('Confirm', AppTheme.successGreen, () {
                    onStatusChange(a['id'] as String, 'confirmed');
                  }),
                if (status == 'confirmed')
                  _actionBtn('Complete', kDoctorBlue, () {
                    onStatusChange(a['id'] as String, 'completed');
                  }),
                const SizedBox(width: 8),
                _actionBtn('Cancel', AppTheme.dangerRed, () {
                  _showCancelDialog(context, a['id'] as String);
                }),
                const SizedBox(width: 8),
                _actionBtn('Details', Colors.white24, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientDetailScreen(appointment: a),
                    ),
                  );
                }),
              ],
            ),
          ] else if (status == 'completed') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _actionBtn('View Patient Details', kDoctorBlue, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientDetailScreen(appointment: a),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Appointment',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to cancel this appointment? The patient will be notified.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              onStatusChange(id, 'cancelled');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
