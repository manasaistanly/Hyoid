import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:hyoid_app/features/doctor/dashboard/doctor_dashboard_screen.dart';
import 'package:hyoid_app/features/doctor/dashboard/patient_requests_screen.dart';
import 'package:hyoid_app/features/doctor/dashboard/reports_screen.dart';
import 'package:hyoid_app/features/doctor/dashboard/prescription_screen.dart';
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
    PatientRequestsScreen(),
    ReportsScreen(),
    PrescriptionScreen(),
    DoctorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 20,
            right: 20,
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
          height: 75,
          decoration: BoxDecoration(
            color: kDoctorBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(35),
            border:
                Border.all(color: kDoctorBlue.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 0, 'Home'),
              _buildNavItem(Icons.pending_actions_rounded, 1, 'Requests'),
              _buildNavItem(Icons.assignment_rounded, 2, 'Reports'),
              _buildNavItem(Icons.medication_rounded, 3, 'Prescribe'),
              _buildNavItem(Icons.person_rounded, 4, 'Profile'),
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
        width: 60,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? kDoctorBlue : Colors.white38,
              size: isActive ? 26 : 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? kDoctorBlue : Colors.white38,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
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
