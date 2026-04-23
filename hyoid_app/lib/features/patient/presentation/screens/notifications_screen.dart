import 'package:flutter/material.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/core/state/globals.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.check_circle_outline,
      'color': AppTheme.successGreen,
      'title': 'Booking Confirmed!',
      'subtitle':
          'Your appointment with Dr. Sarah Jenkins is confirmed for today.',
      'time': '10:32 AM',
      'isRead': false,
    },
    {
      'icon': Icons.directions_car,
      'color': AppTheme.orangeAccent,
      'title': 'Technician Assigned',
      'subtitle':
          'Dr. Sarah Jenkins has been assigned and is preparing to leave.',
      'time': '10:36 AM',
      'isRead': false,
    },
    {
      'icon': Icons.location_on,
      'color': Colors.blueAccent,
      'title': 'On the Way!',
      'subtitle':
          'Your technician is now heading to your location. ETA: 14 mins.',
      'time': '10:52 AM',
      'isRead': false,
    },
    {
      'icon': Icons.medical_services_outlined,
      'color': Colors.purpleAccent,
      'title': 'Upcoming Consultation',
      'subtitle':
          'Reminder: You have a general consultation scheduled tomorrow.',
      'time': 'Yesterday',
      'isRead': true,
    },
    {
      'icon': Icons.local_hospital,
      'color': AppTheme.dangerRed,
      'title': 'SOS Alert Triggered',
      'subtitle': 'An emergency SOS was activated. Our team has been notified.',
      'time': '2 days ago',
      'isRead': true,
    },
    {
      'icon': Icons.star_outline,
      'color': Colors.amber,
      'title': 'Rate Your Experience',
      'subtitle':
          'How was your last visit? Leave a rating for Dr. Sarah Jenkins.',
      'time': '3 days ago',
      'isRead': true,
    },
  ];

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
    globalNotifCount.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const CircleAvatar(
                          backgroundColor: AppTheme.darkSurface,
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _markAllRead,
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        color: AppTheme.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final n = _notifications[index];
                  return _buildNotificationCard(index, n);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(int index, Map<String, dynamic> n) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _notifications[index]['isRead'] = true;
          // Recalculate badge count
          globalNotifCount.value = _notifications
              .where((n) => n['isRead'] == false)
              .length;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n['isRead'] ? AppTheme.darkSurface : AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n['isRead']
                ? AppTheme.borderCol
                : (n['color'] as Color).withValues(alpha: 0.5),
            width: n['isRead'] ? 1 : 1.5,
          ),
          boxShadow: n['isRead']
              ? []
              : [
                  BoxShadow(
                    color: (n['color'] as Color).withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (n['color'] as Color).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                n['icon'] as IconData,
                color: n['color'] as Color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          n['title'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: n['isRead']
                                ? FontWeight.w600
                                : FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (!n['isRead'])
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: n['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    n['subtitle'] as String,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    n['time'] as String,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
