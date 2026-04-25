import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart' show kDoctorBlue;
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/auth/presentation/screens/login_screen.dart';
import 'package:hyoid_app/features/doctor/data/services/doctor_api_service.dart';

import 'package:url_launcher/url_launcher.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final DoctorApiService _apiService = DoctorApiService();
  
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _specialtyCtrl = TextEditingController();
  final TextEditingController _qualCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();
  final TextEditingController _feeCtrl = TextEditingController();
  final TextEditingController _safetyNumCtrl = TextEditingController();
  
  bool _acceptingBookings = true;
  bool _isLoading = true;
  bool _saving = false;
  bool _saved = false;
  String _rating = "0.0";
  String _totalPatients = "0";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _apiService.getProfile();
      if (mounted) {
        if (profile.isNotEmpty) {
          setState(() {
            _nameCtrl.text = profile['name'] ?? '';
            _specialtyCtrl.text = profile['specialty'] ?? '';
            _qualCtrl.text = profile['qualifications'] ?? '';
            _bioCtrl.text = profile['bio'] ?? '';
            _feeCtrl.text = profile['consultationFee']?.toString() ?? '0';
            _safetyNumCtrl.text = profile['safetyNumber'] ?? '';
            _acceptingBookings = profile['acceptingBookings'] ?? true;
            _rating = profile['rating']?.toString() ?? "0.0";
            _totalPatients = profile['totalPatients']?.toString() ?? "0";
          });
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile. Please check your connection.')),
        );
      }
    }
  }

  Future<void> _makeSafetyCall() async {
    final number = _safetyNumCtrl.text;
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a safety number first.')),
      );
      return;
    }
    
    final Uri url = Uri.parse('tel:${number.replaceAll(' ', '')}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not initiate call.')),
      );
    }
  }

  void _save() async {
    setState(() => _saving = true);
    
    final success = await _apiService.updateProfile({
      'name': _nameCtrl.text,
      'specialty': _specialtyCtrl.text,
      'qualifications': _qualCtrl.text,
      'bio': _bioCtrl.text,
      'consultationFee': int.tryParse(_feeCtrl.text) ?? 0,
      'safetyNumber': _safetyNumCtrl.text,
      'acceptingBookings': _acceptingBookings,
    });

    if (mounted) {
      setState(() {
        _saving = false;
        if (success) _saved = true;
      });
      
      if (success) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _saved = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
      }
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specialtyCtrl.dispose();
    _qualCtrl.dispose();
    _bioCtrl.dispose();
    _feeCtrl.dispose();
    _safetyNumCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: kDoctorBlue)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
        actions: [
          TextButton(
            onPressed: _logout,
            child: const Text('Logout', style: TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Safety Protocols ─────────────────────────────────────
            GestureDetector(
              onTap: _makeSafetyCall,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kDoctorBlue.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emergency_rounded, color: kDoctorBlue, size: 22),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Emergency Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          Text('Trigger SOS call to safety number', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // ── Avatar ───────────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kDoctorBlue.withValues(alpha: 0.15),
                      border: Border.all(color: kDoctorBlue, width: 2.5),
                    ),
                    child: const Icon(Icons.person_rounded, color: kDoctorBlue, size: 52),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: kDoctorBlue, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '$_rating ★  ·  $_totalPatients patients',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),

            const SizedBox(height: 32),

            // ── Accepting Bookings Toggle ─────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: (_acceptingBookings ? AppTheme.successGreen : AppTheme.dangerRed).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _acceptingBookings ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: _acceptingBookings ? AppTheme.successGreen : AppTheme.dangerRed,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Online Visibility', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        Text(
                          _acceptingBookings ? 'Patients can find you' : 'You are currently offline',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _acceptingBookings,
                    activeThumbColor: AppTheme.successGreen,
                    inactiveThumbColor: AppTheme.dangerRed,
                    onChanged: (v) => setState(() => _acceptingBookings = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            _sectionLabel('Professional Info'),
            const SizedBox(height: 16),

            _inputField('Full Name', _nameCtrl, Icons.badge_rounded),
            _inputField('Specialty', _specialtyCtrl, Icons.medical_services_rounded),
            _inputField('Qualifications', _qualCtrl, Icons.school_rounded),
            _inputField('Consultation Fee (₹)', _feeCtrl, Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
            
            const SizedBox(height: 16),
            _sectionLabel('Security Settings'),
            const SizedBox(height: 16),
            _inputField('Emergency Safety Number', _safetyNumCtrl, Icons.phone_forwarded_rounded, keyboardType: TextInputType.phone),

            const SizedBox(height: 16),
            _sectionLabel('Bio'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF333333), width: 1.5),
              ),
              child: TextField(
                controller: _bioCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Write a short bio...',
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Save button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(_saved ? Icons.check_rounded : Icons.save_rounded, color: Colors.white),
                label: Text(
                  _saved ? 'Profile Saved!' : _saving ? 'Saving...' : 'Save Profile',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saved ? AppTheme.successGreen : kDoctorBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Row(
    children: [
      Container(width: 4, height: 18, decoration: BoxDecoration(color: kDoctorBlue, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
    ],
  );

  Widget _inputField(String label, TextEditingController ctrl, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          prefixIcon: Icon(icon, color: kDoctorBlue, size: 20),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF333333))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF333333))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: kDoctorBlue, width: 1.5)),
        ),
      ),
    );
  }
}
