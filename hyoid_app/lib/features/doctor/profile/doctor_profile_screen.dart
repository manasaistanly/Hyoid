import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart'
    show kDoctorBlue;
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/auth/presentation/screens/login_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  // Mock profile (mirrors GET /api/doctor/profile)
  final TextEditingController _nameCtrl = TextEditingController(
    text: 'Dr. Sarah Jenkins',
  );
  final TextEditingController _specialtyCtrl = TextEditingController(
    text: 'Cardiologist',
  );
  final TextEditingController _qualCtrl = TextEditingController(
    text: 'MBBS, MD (Cardiology), FACC',
  );
  final TextEditingController _bioCtrl = TextEditingController(
    text:
        'Senior cardiologist with 12+ years of experience in interventional cardiology and heart failure management.',
  );
  final TextEditingController _feeCtrl = TextEditingController(text: '800');
  bool _acceptingBookings = true;
  bool _saving = false;
  bool _saved = false;

  void _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() {
      _saving = false;
      _saved = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _logout,
            child: const Text(
              'Logout',
              style: TextStyle(
                color: AppTheme.dangerRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    child: const Icon(
                      Icons.person_rounded,
                      color: kDoctorBlue,
                      size: 52,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: kDoctorBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                '4.9 ★  ·  1,240 patients',
                style: TextStyle(color: Colors.white54, fontSize: 13),
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
                  color:
                      (_acceptingBookings
                              ? AppTheme.successGreen
                              : AppTheme.dangerRed)
                          .withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _acceptingBookings
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _acceptingBookings
                        ? AppTheme.successGreen
                        : AppTheme.dangerRed,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Accepting New Appointments',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _acceptingBookings
                              ? 'Patients can book slots'
                              : 'Booking is closed',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
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
            _inputField(
              'Specialty',
              _specialtyCtrl,
              Icons.medical_services_rounded,
            ),
            _inputField('Qualifications', _qualCtrl, Icons.school_rounded),
            _inputField(
              'Consultation Fee (₹)',
              _feeCtrl,
              Icons.currency_rupee_rounded,
              keyboardType: TextInputType.number,
            ),

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
                decoration: InputDecoration(
                  hintText: 'Write a short bio...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Notification Prefs ──────────────────────────────────
            _sectionLabel('Notification Preferences'),
            const SizedBox(height: 12),
            _notifToggle('New booking received', true),
            _notifToggle('Booking cancelled by patient', true),
            _notifToggle('Daily appointment summary', false),

            const SizedBox(height: 28),

            // ── Save button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _saved ? Icons.check_rounded : Icons.save_rounded,
                        color: Colors.white,
                      ),
                label: Text(
                  _saved
                      ? 'Profile Saved!'
                      : _saving
                      ? 'Saving...'
                      : 'Save Profile',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saved ? AppTheme.successGreen : kDoctorBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
          color: kDoctorBlue,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ],
  );

  Widget _inputField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: kDoctorBlue, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _notifToggle(String label, bool initialValue) {
    return StatefulBuilder(
      builder: (_, setLocal) {
        bool val = initialValue;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Switch(
                value: val,
                activeThumbColor: kDoctorBlue,
                onChanged: (v) => setLocal(() => val = v),
              ),
            ],
          ),
        );
      },
    );
  }
}
