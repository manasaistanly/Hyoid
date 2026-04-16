import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/screens/booking_screen.dart';

class ServicesHubScreen extends StatelessWidget {
  const ServicesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        title: const Text("All Services", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.darkSurface,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text("Select a Service", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
             const SizedBox(height: 24),
            _buildServiceOption(
              context,
              "Consult a Doctor",
              "Schedule an online or in-person visit with specialists.",
              Icons.medical_services,
              Colors.blue,
            ),
            _buildServiceOption(
              context,
              "Book a Nurse",
              "Request certified nursing care at your ward or home.",
              Icons.supervised_user_circle,
              AppTheme.orangeAccent,
            ),
            _buildServiceOption(
              context,
              "Doorstep Lab Test",
              "Get blood tests and diagnostics done from your location.",
              Icons.science_outlined,
              Colors.purpleAccent,
            ),
            _buildServiceOption(
              context,
              "Order Pharmacy",
              "Fulfill prescriptions automatically delivered to you.",
              Icons.local_pharmacy_outlined,
              AppTheme.successGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceOption(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingScreen()));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderCol, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}
