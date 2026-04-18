import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/screens/home_screen.dart';
import 'package:hyoid_app/screens/vitals_screen.dart';
import 'package:hyoid_app/screens/services_hub_screen.dart';
import 'package:hyoid_app/screens/profile_screen.dart';
import 'package:hyoid_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _holdController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const VitalsScreen(),
    const SizedBox(), // Placeholder for SOS center button
    const ServicesHubScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {}); // Animate progress ring
        if (_holdController.isCompleted) {
          _triggerEmergency();
          _holdController.reset();
        }
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _triggerEmergency() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🚨 SOS Successfully Activated!"),
        backgroundColor: AppTheme.dangerRed,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 32),
                const SizedBox(width: 12),
                const Text("Emergency Alert Sent", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatusStep("Alert sent to nurses", true),
            _buildStatusStep("Your location shared", true),
            _buildStatusStep("Doctor notified", true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.borderCol,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Cancel Alert"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStep(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle_outline : Icons.circle_outlined, 
               color: isDone ? AppTheme.orangeAccent : Colors.white54, 
               size: 20),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: isDone ? Colors.white : Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: Stack(
        children: [
          _screens[_currentIndex],
          
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _buildGlassNavBar(),
          ),
          
          Positioned(
            bottom: 26,
            left: MediaQuery.of(context).size.width / 2 - 38,
            child: _buildSOSButton(),
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
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_outlined, 0, 'Home'),
              _buildNavItem(Icons.auto_graph, 1, 'Stats'),
              const SizedBox(width: 56), // Space for center SOS button
              _buildNavItem(Icons.calendar_month_outlined, 3, 'Booking'),
              _buildNavItem(Icons.person_outline, 4, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavTap(int index) async {
    if (index == 1 || index == 3 || index == 4) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        return;
      }
    }
    setState(() => _currentIndex = index);
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _handleNavTap(index),
      child: Container(
        width: 60,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.orangeAccent : Colors.white54,
              size: isActive ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.orangeAccent : Colors.white54,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton() {
    return GestureDetector(
      onTapDown: (_) => _holdController.forward(),
      onTapUp: (_) => _holdController.reverse(),
      onTapCancel: () => _holdController.reverse(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: _holdController.value,
                  strokeWidth: 4,
                  color: AppTheme.dangerRed,
                  backgroundColor: Colors.transparent,
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Color.lerp(AppTheme.orangeAccent, AppTheme.dangerRed, _holdController.value)!,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.orangeAccent.withValues(alpha: 0.4 + (_holdController.value * 0.4)),
                      blurRadius: 15 + (_holdController.value * 10),
                      spreadRadius: 2 + (_holdController.value * 5),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    "SOS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18 + (_holdController.value * 4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'SOS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
