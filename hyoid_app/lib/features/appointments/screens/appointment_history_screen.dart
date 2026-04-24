import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import '../../../services/appointment_provider.dart';
import 'track_appointment_screen.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppointmentProvider.instance.loadUserAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: AppTheme.darkSurface,
      ),
      body: ListenableBuilder(
        listenable: AppointmentProvider.instance,
        builder: (context, _) {
          final provider = AppointmentProvider.instance;

          if (provider.isLoading && provider.appointments.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.orangeAccent));
          }

          if (provider.errorMessage != null && provider.appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.dangerRed, size: 48),
                  const SizedBox(height: 16),
                  Text('Failed to load history', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                  TextButton(
                    onPressed: provider.loadUserAppointments,
                    child: const Text('Retry', style: TextStyle(color: AppTheme.orangeAccent)),
                  )
                ],
              ),
            );
          }

          if (provider.appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_outlined, color: Colors.white.withValues(alpha: 0.2), size: 64),
                  const SizedBox(height: 16),
                  Text('No appointments found', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.appointments.length,
            itemBuilder: (context, index) {
              final apt = provider.appointments[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TrackAppointmentScreen(appointment: apt)),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderCol),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                apt.type == 'doctor' ? Icons.local_hospital_outlined : Icons.medication_outlined, 
                                color: AppTheme.orangeAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${apt.type[0].toUpperCase()}${apt.type.substring(1)} Visit',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          _buildStatusBadge(apt.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        apt.symptoms,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time: ${apt.preferredTime.isNotEmpty ? apt.preferredTime.substring(0, 10) : "N/A"}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                          ),
                          if (apt.priority == 'urgent')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.dangerRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('URGENT', style: TextStyle(color: AppTheme.dangerRed, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    
    switch (status.toLowerCase()) {
      case 'completed':
        fg = AppTheme.successGreen;
        bg = AppTheme.successGreen.withValues(alpha: 0.1);
        break;
      case 'pending':
        fg = Colors.orangeAccent;
        bg = Colors.orangeAccent.withValues(alpha: 0.1);
        break;
      case 'confirmed':
      case 'assigned':
        fg = const Color(0xFF60A5FA); // blue
        bg = const Color(0x2660A5FA);
        break;
      default:
        fg = Colors.white54;
        bg = Colors.white.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
