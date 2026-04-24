import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment_model.dart';
import 'track_appointment_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_prompt_sheet.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  final AppointmentProvider _provider = AppointmentProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isGuest) {
        Navigator.pop(context);
        showLoginPromptSheet(context, actionDescription: 'view your appointment history');
      } else {
        _loadAppointments();
      }
    });
  }

  Future<void> _loadAppointments() async {
    // Load user appointments
    await _provider.fetchMyAppointments();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber;
      case 'contacted':
        return Colors.blue;
      case 'assigned':
        return Colors.purple;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.darkSurface,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AnimatedBuilder(
        animation: _provider,
        builder: (context, child) {
          if (_provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.orangeAccent),
            );
          }

          if (_provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    _provider.error.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: _loadAppointments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_provider.appointments.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadAppointments,
              child: ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      'No appointments found.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAppointments,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _provider.appointments.length,
              itemBuilder: (context, index) {
                final appt = _provider.appointments[index];
                return _buildAppointmentCard(appt);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appt) {
    final statusColor = _getStatusColor(appt.status);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TrackAppointmentScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    appt.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  appt.preferredTime.split(' ')[0], // just date
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appt.type == 'doctor'
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    appt.type == 'doctor'
                        ? Icons.medical_services
                        : Icons.supervised_user_circle,
                    color: appt.type == 'doctor' ? Colors.blue : Colors.orange,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appt.type[0].toUpperCase()}${appt.type.substring(1)} Appointment',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appt.symptoms,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
