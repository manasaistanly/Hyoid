import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:hyoid_app/features/doctor/dashboard/doctor_dashboard_screen.dart';
import 'package:hyoid_app/features/doctor/appointments/doctor_appointments_screen.dart';
import 'package:hyoid_app/features/doctor/schedule/doctor_schedule_screen.dart';
import 'package:hyoid_app/features/doctor/profile/doctor_profile_screen.dart';

// Doctor portal accent color
const Color kDoctorBlue = Color(0xFF60A5FA);
const Color kDoctorBlueDim = Color(0x2260A5FA);

class DoctorShell extends StatefulWidget {
  const DoctorShell({super.key});

  @override
  State<DoctorShell> createState() => _DoctorShellState();
}

class _DoctorShellState extends State<DoctorShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DoctorDashboardScreen(),
    DoctorAppointmentsScreen(),
    DoctorScheduleScreen(),
    DoctorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          _screens[_currentIndex],
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _buildGlassNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: kDoctorBlue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(35),
            border:
                Border.all(color: kDoctorBlue.withValues(alpha: 0.15), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard_rounded, 0, 'Dashboard'),
              _buildNavItem(Icons.event_note_rounded, 1, 'Appointments'),
              _buildNavItem(Icons.calendar_month_rounded, 2, 'Schedule'),
              _buildNavItem(Icons.person_rounded, 3, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        width: 70,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? kDoctorBlue : Colors.white38,
              size: isActive ? 28 : 24,
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: kDoctorBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
