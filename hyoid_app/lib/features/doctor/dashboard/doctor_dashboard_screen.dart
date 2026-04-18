import 'package:flutter/material.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart'
    show kDoctorBlue;
import 'package:hyoid_app/features/doctor/appointments/doctor_appointments_screen.dart';
import 'package:hyoid_app/theme/app_theme.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  // Mock data (mirrors GET /api/doctor/stats)
  final _stats = {
    'todayCount': 8,
    'pendingCount': 3,
    'completedCount': 5,
    'weeklyCount': 34,
    'cancellationRate': 12.5,
  };
  final _next = {
    'patientName': 'Arjun Sharma',
    'patientAge': 34,
    'time': '11:30 AM',
    'type': 'in-person',
    'status': 'confirmed',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
          children: [
            // ── Header ─────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kDoctorBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: kDoctorBlue.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.medical_services_rounded,
                      color: kDoctorBlue, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning,',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                    ),
                    const Text(
                      'Dr. Sarah Jenkins',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kDoctorBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kDoctorBlue.withValues(alpha: 0.3)),
                  ),
                  child: const Text('Doctor',
                      style: TextStyle(
                          color: kDoctorBlue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Today's Overview label ──────────────────────────────
            _sectionLabel("Today's Overview"),
            const SizedBox(height: 14),

            // ── Stat Chips Row ──────────────────────────────────────
            Row(
              children: [
                _buildStatCard(
                    'Total', '${_stats['todayCount']}',
                    Icons.calendar_today_rounded,
                    kDoctorBlue),
                const SizedBox(width: 12),
                _buildStatCard(
                    'Pending', '${_stats['pendingCount']}',
                    Icons.hourglass_top_rounded,
                    AppTheme.warningOrange),
                const SizedBox(width: 12),
                _buildStatCard(
                    'Done', '${_stats['completedCount']}',
                    Icons.check_circle_rounded,
                    AppTheme.successGreen),
              ],
            ),

            const SizedBox(height: 28),

            // ── Weekly snapshot ─────────────────────────────────────
            _sectionLabel('This Week'),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildWideStatCard(
                  icon: Icons.bar_chart_rounded,
                  label: 'Total Bookings',
                  value: '${_stats['weeklyCount']}',
                  color: kDoctorBlue,
                ),
                const SizedBox(width: 12),
                _buildWideStatCard(
                  icon: Icons.cancel_outlined,
                  label: 'Cancellation',
                  value: '${_stats['cancellationRate']}%',
                  color: AppTheme.dangerRed,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Next Appointment ────────────────────────────────────
            _sectionLabel('Next Appointment'),
            const SizedBox(height: 14),
            _buildNextAppointmentCard(),

            const SizedBox(height: 28),

            // ── Quick Actions ───────────────────────────────────────
            _sectionLabel('Quick Actions'),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildQuickAction(
                  Icons.event_note_rounded,
                  'All Appointments',
                  kDoctorBlue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DoctorAppointmentsScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                _buildQuickAction(
                  Icons.add_circle_outline_rounded,
                  'Add Availability',
                  AppTheme.successGreen,
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildWideStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kDoctorBlue.withValues(alpha: 0.2), const Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kDoctorBlue.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: kDoctorBlue.withValues(alpha: 0.1),
              blurRadius: 16,
              spreadRadius: 1)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: kDoctorBlue.withValues(alpha: 0.15),
            child: const Icon(Icons.person_rounded,
                color: kDoctorBlue, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _next['patientName'] as String,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Age ${_next['patientAge']} · ${(_next['type'] as String).toUpperCase()}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: kDoctorBlue, size: 14),
                    const SizedBox(width: 4),
                    Text(_next['time'] as String,
                        style: const TextStyle(
                            color: kDoctorBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    const SizedBox(width: 12),
                    _statusChip(_next['status'] as String),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: kDoctorBlue, size: 16),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final colors = {
      'confirmed': AppTheme.successGreen,
      'pending': AppTheme.warningOrange,
      'completed': kDoctorBlue,
      'cancelled': AppTheme.dangerRed,
    };
    final color = colors[status] ?? Colors.white38;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
