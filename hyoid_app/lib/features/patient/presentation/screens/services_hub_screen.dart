import 'package:flutter/material.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/patient/presentation/screens/booking_screen.dart';
import 'package:hyoid_app/features/patient/presentation/screens/lab_catalog_screen.dart';
import 'package:hyoid_app/features/patient/data/models/service_model.dart';
import 'package:hyoid_app/features/patient/data/services/patient_api_service.dart';

class ServicesHubScreen extends StatefulWidget {
  const ServicesHubScreen({super.key});

  @override
  State<ServicesHubScreen> createState() => _ServicesHubScreenState();
}

class _ServicesHubScreenState extends State<ServicesHubScreen> {
  final PatientApiService _apiService = PatientApiService();
  late Future<List<ServiceBooking>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _fetchServices();
  }

  Future<List<ServiceBooking>> _fetchServices() async {
    final data = await _apiService.getServices();
    return data.map((json) => ServiceBooking.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        title: const Text(
          'All Services',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: AppTheme.darkSurface,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: FutureBuilder<List<ServiceBooking>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.orangeAccent));
          }
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white24, size: 48),
                  const SizedBox(height: 16),
                  const Text('Failed to load services', style: TextStyle(color: Colors.white54)),
                  TextButton(
                    onPressed: () => setState(() => _servicesFuture = _fetchServices()),
                    child: const Text('Retry', style: TextStyle(color: AppTheme.orangeAccent)),
                  ),
                ],
              ),
            );
          }

          final services = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a Service',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Premium healthcare at your fingertips',
                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.45)),
                ),
                const SizedBox(height: 28),
                ...services.map((s) => _ServiceCard(service: s)),
              ],
            ),
          );
        },
      ),
    );
  }
}

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
            builder: (_) => s.title.contains('Lab')
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
          color: _pressed ? const Color(0xFF222222) : AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _pressed ? s.color.withValues(alpha: 0.6) : const Color(0xFF333333),
            width: 1.5,
          ),
          boxShadow: _pressed
              ? [BoxShadow(color: s.glowColor, blurRadius: 18, spreadRadius: 1)]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: s.glowColor,
                shape: BoxShape.circle,
                border: Border.all(color: s.color.withValues(alpha: 0.35), width: 1.5),
              ),
              child: Icon(s.icon, color: s.color, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  Text(s.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: s.color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(Icons.arrow_forward_ios_rounded, color: s.color, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}
