import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Profile Settings",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),

          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.borderCol,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Tesst user",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Patient ID: HY-293812",
                  style: TextStyle(fontSize: 14, color: AppTheme.orangeAccent),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          _buildInfoRow(
            "Blood Group",
            "O+",
            Icons.bloodtype,
            AppTheme.dangerRed,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            "Assigned Ward",
            "ICU - Bed 4",
            Icons.local_hospital,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            "Emergency Contact",
            "+1 234 567 890",
            Icons.contact_phone,
            AppTheme.warningOrange,
          ),

          const SizedBox(height: 40),
          const Text(
            "Previous Medical Records",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          _buildRecordCard(
            "Oct 12, 2023",
            "Complete Blood Count",
            "All levels normal",
            Icons.science_outlined,
            Colors.purpleAccent,
          ),
          const SizedBox(height: 12),
          _buildRecordCard(
            "Sep 04, 2023",
            "General Consultation",
            "Dr. Alice Smith",
            Icons.medical_services_outlined,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildRecordCard(
            "Jun 15, 2023",
            "Chest X-Ray",
            "No abnormalities detected",
            Icons.personal_injury,
            AppTheme.orangeAccent,
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "View Full History",
                style: TextStyle(
                  color: AppTheme.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, color: AppTheme.dangerRed),
              label: const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.dangerRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.dangerRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String val,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderCol),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const Spacer(),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(
    String date,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderCol),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
