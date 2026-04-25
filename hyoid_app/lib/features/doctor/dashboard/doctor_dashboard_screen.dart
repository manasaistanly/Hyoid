import 'package:flutter/material.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart' show kDoctorBlue;
import 'package:hyoid_app/features/doctor/data/services/doctor_api_service.dart';
import 'package:hyoid_app/features/doctor/data/models/doctor_request.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final DoctorApiService _apiService = DoctorApiService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'totalToday': 0,
    'pending': 0,
    'emergency': 0,
    'completed': 0,
  };
  DoctorRequest? _nextCase;
  String? _safetyNumber;
  String _doctorName = "Doctor";

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getStats();
      setState(() {
        _stats = data;
        _safetyNumber = data['safetyNumber'];
        _doctorName = data['name'] ?? "Doctor";
        if (data['nextCase'] != null) {
          _nextCase = DoctorRequest.fromJson(data['nextCase']);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeSafetyCall() async {
    if (_safetyNumber == null || _safetyNumber!.isEmpty) {
      // Try fetching it one more time if it's null (maybe dashboard haven't refreshed)
      try {
        final data = await _apiService.getStats();
        _safetyNumber = data['safetyNumber'];
      } catch (_) {}
    }

    if (_safetyNumber == null || _safetyNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Safety number not found. Please set it in your Profile.'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }
    
    final cleanNumber = _safetyNumber!.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri url = Uri.parse('tel:$cleanNumber');
    
    if (await canLaunchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calling Safety Number: $_safetyNumber...')),
      );
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not initiate call. Please check device permissions.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: kDoctorBlue,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
            children: [
              // ── Header ─────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kDoctorBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: kDoctorBlue.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: const Icon(Icons.medical_services_rounded,
                        color: kDoctorBlue, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                        ),
                        Text(
                          'Dr. $_doctorName',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ── SOS Button ─────────────────────────────────────────
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => _buildSOSMenu(context),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.dangerRed, AppTheme.dangerRed.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.dangerRed.withValues(alpha: 0.2),
                            blurRadius: 6,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: const Icon(Icons.sos_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kDoctorBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: kDoctorBlue.withValues(alpha: 0.2)),
                    ),
                    child: const Text('Doctor',
                        style: TextStyle(
                            color: kDoctorBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _sectionLabel('Today\'s Overview'),
              const SizedBox(height: 16),

              // ── Stats Grid ──────────────────────────────────────────
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard('Total Today', _stats['totalToday'].toString(),
                      Icons.people_alt_rounded, kDoctorBlue),
                  _buildStatCard('Pending', _stats['pending'].toString(),
                      Icons.hourglass_empty_rounded, Colors.orange),
                  _buildStatCard('Emergency', _stats['emergency'].toString(),
                      Icons.notification_important_rounded, AppTheme.dangerRed),
                  _buildStatCard('Completed', _stats['completed'].toString(),
                      Icons.check_circle_rounded, AppTheme.successGreen),
                ],
              ),

              const SizedBox(height: 32),
              _sectionLabel('Next Priority Case'),
              const SizedBox(height: 16),

              // ── Next Case Card ──────────────────────────────────────
              _buildNextCaseCard(),

              const SizedBox(height: 32),
              _sectionLabel('Quick Access'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.7), size: 24),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNextCaseCard() {
    if (_nextCase == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            const Icon(Icons.done_all_rounded, color: AppTheme.successGreen, size: 40),
            const SizedBox(height: 12),
            const Text('All caught up!',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text('No pending cases at the moment.',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        // Navigate to details
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A1A),
              _nextCase!.priority == RequestPriority.emergency
                  ? AppTheme.dangerRed.withValues(alpha: 0.05)
                  : const Color(0xFF151515)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _nextCase!.priority == RequestPriority.emergency
                ? AppTheme.dangerRed.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: kDoctorBlue.withValues(alpha: 0.1),
                  child: const Icon(Icons.person_rounded, color: kDoctorBlue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_nextCase!.patientName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17)),
                      Text('${_nextCase!.age} Years · ${_nextCase!.symptoms}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white38, fontSize: 13)),
                    ],
                  ),
                ),
                if (_nextCase!.priority == RequestPriority.emergency)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('EMERGENCY',
                        style: TextStyle(
                            color: AppTheme.dangerRed,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kDoctorBlue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Review Case',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'EMERGENCY ASSISTANCE',
            style: TextStyle(
              color: AppTheme.dangerRed,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSOSOption(
                context: context,
                label: 'Ambulance',
                icon: Icons.emergency_share_rounded,
                color: AppTheme.dangerRed,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Requesting emergency ambulance...')),
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildSOSOption(
                context: context,
                label: 'Safety',
                icon: Icons.security_rounded,
                color: kDoctorBlue,
                onTap: () {
                  Navigator.pop(context);
                  _makeSafetyCall();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSOSOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 42),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      );
}
