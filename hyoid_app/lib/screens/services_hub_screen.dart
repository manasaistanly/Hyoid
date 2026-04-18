import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/screens/booking_screen.dart';
import 'package:hyoid_app/screens/lab_catalog_screen.dart';
import 'package:hyoid_app/models/service_model.dart';

class ServicesHubScreen extends StatelessWidget {
  const ServicesHubScreen({super.key});

  static const services = [
    ServiceBooking(
      title: 'Consult a Doctor',
      subtitle: 'Schedule an online or in-person visit with specialists.',
      providerName: 'Dr. Sarah Jenkins',
      specialization: 'Cardiologist • Generic Hosp',
      icon: Icons.medical_services_rounded,
      color: Color(0xFF60A5FA), // sky blue
      glowColor: Color(0x2660A5FA),
      priceFrom: 500,
    ),
    ServiceBooking(
      title: 'Book a Nurse',
      subtitle: 'Request certified nursing care at your ward or home.',
      providerName: 'Nurse Clara Evans',
      specialization: 'ICU Specialist • 8+ Years Exp',
      icon: Icons.supervised_user_circle_rounded,
      color: Color(0xFFE85D1E), // AppTheme.orangeAccent
      glowColor: Color(0x26E85D1E),
      priceFrom: 800,
    ),
    ServiceBooking(
      title: 'Doorstep Lab Test',
      subtitle: 'Get blood tests and diagnostics done from your location.',
      providerName: 'Apex Diagnostics',
      specialization: 'Certified Phlebotomist • LabCorp',
      icon: Icons.science_rounded,
      color: Color(0xFFA78BFA), // soft violet
      glowColor: Color(0x26A78BFA),
      priceFrom: 300,
    ),
    ServiceBooking(
      title: 'Order Pharmacy',
      subtitle: 'Fulfill prescriptions automatically delivered to you.',
      providerName: 'HealthLine Pharma',
      specialization: 'Verified Pharmacist • Express Delivery',
      icon: Icons.local_pharmacy_rounded,
      color: Color(0xFF4ADE80), // AppTheme.successGreen
      glowColor: Color(0x264ADE80),
      priceFrom: 200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        title: const Text(
          'All Services',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppTheme.darkSurface,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.orangeAccent.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            const Text(
              'Select a Service',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Premium healthcare at your fingertips',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.45),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),

            // ── Service Cards ────────────────────────────────────
            ...services.map(
              (s) => _ServiceCard(service: s),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Service card widget ───────────────────────────────────────────────────────

class _ServiceCard extends StatefulWidget {
  final ServiceBooking service;
  const _ServiceCard({required this.service});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => s.title == 'Doorstep Lab Test'
                ? const LabCatalogScreen()
                : BookingScreen(booking: s),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        transform: Matrix4.diagonal3Values(_pressed ? 0.974 : 1.0, _pressed ? 0.974 : 1.0, 1.0),
        decoration: BoxDecoration(
          color: _pressed
              ? const Color(0xFF222222)
              : AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _pressed
                ? s.color.withValues(alpha: 0.6)
                : const Color(0xFF333333),
            width: 1.5,
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: s.glowColor,
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: s.glowColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: s.color.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Icon(s.icon, color: s.color, size: 28),
            ),
            const SizedBox(width: 18),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    s.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Arrow chip
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: s.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: s.color,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
