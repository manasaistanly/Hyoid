// lib/screens/login_screen.dart
// ─────────────────────────────────────────────────────────────
// Login screen — UI is UNCHANGED from original.
// Only the logic wiring has been replaced:
//   _sendOtp()    → AuthProvider.sendOtp()  → real Twilio SMS
//   _verifyOtp()  → AuthProvider.verifyOtp() → real JWT from server
//   _googleSignIn() → AuthProvider.googleSignIn() → real Google OAuth
//
// Post-auth routing:
//   requiresPayment == true  → PaymentScreen
//   requiresPayment == false → HomeScreen (role-based)
//
// OTP input: 6 boxes, auto-focus, auto-submit on last digit.
// Resend countdown: 60 seconds after OTP is sent.
//
// Connects to: AuthProvider, PaymentScreen, MainNavigationScreen, DoctorShell
// ─────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/screens/main_navigation_screen.dart';
import 'package:hyoid_app/screens/register_screen.dart';
import 'package:hyoid_app/screens/payment_screen.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart';
import 'package:hyoid_app/providers/auth_provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  String _completePhoneNumber = '';

  // Resend countdown
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── OTP Countdown ────────────────────────────────────────────

  void _startCountdown() {
    setState(() => _resendCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown <= 1) {
        t.cancel();
        setState(() => _resendCountdown = 0);
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  // ── Send OTP ─────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    // Note: If you want the full phone number with country code, you would use phone.completeNumber 
    // from IntlPhoneField. For simplicity, we assume auth provider expects what _phoneCtrl holds, or adjust as needed.
    // Assuming backend takes either local or full format, or you can prepend the country code here if not included.
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _showSnack('Please enter a phone number');
      return;
    }
    
    // Using the complete phone number from IntlPhoneField, fallback to +91
    final fullPhone = _completePhoneNumber.isNotEmpty ? _completePhoneNumber : '+91$phone';

    final auth = context.read<AuthProvider>();
    final success = await auth.sendOtp(fullPhone);

    if (!mounted) return;

    if (success) {
      setState(() => _otpSent = true);
      _startCountdown();
    } else {
      _showSnack(auth.errorMessage ?? 'Failed to send OTP');
    }
  }

  // ── Resend OTP ───────────────────────────────────────────────

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;
    for (final c in _otpCtrls) {
      c.clear();
    }
    await _sendOtp();
  }

  // ── Verify OTP ───────────────────────────────────────────────

  Future<void> _verifyOtp() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 6) {
      _showSnack('Please enter the 6-digit OTP');
      return;
    }

    final phone = _phoneCtrl.text.trim();
    final fullPhone = _completePhoneNumber.isNotEmpty ? _completePhoneNumber : '+91$phone';
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(fullPhone, otp);

    if (!mounted) return;

    if (success) {
      _navigateAfterAuth(auth);
    } else {
      _showSnack(auth.errorMessage ?? 'Invalid OTP. Please try again.');
      // Clear OTP boxes on failure
      for (final c in _otpCtrls) {
        c.clear();
      }
      _otpFocusNodes.first.requestFocus();
    }
  }

  // ── Google Sign-In ───────────────────────────────────────────

  Future<void> _googleSignIn() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.googleSignIn();

    if (!mounted) return;

    if (success) {
      _navigateAfterAuth(auth);
    } else if (auth.errorMessage != null) {
      _showSnack(auth.errorMessage!);
    }
    // If cancelled (no error), do nothing
  }

  // ── Post-auth Navigation ─────────────────────────────────────

  void _navigateAfterAuth(AuthProvider auth) {
    if (auth.requiresPayment) {
      // New or unpaid user → payment screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PaymentScreen()),
        (route) => false,
      );
    } else {
      // Paid user → role-based home
      _navigateToHome(auth.currentUser?.role ?? 'patient');
    }
  }

  void _navigateToHome(String role) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => role == 'doctor'
            ? const DoctorShell()
            : const MainNavigationScreen(),
      ),
      (route) => false,
    );
  }

  // ── Snack helper ─────────────────────────────────────────────

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;
    const accent = AppTheme.orangeAccent;

    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white, onPressed: () => Navigator.pop(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Welcome back to',
                  style: TextStyle(fontSize: 20, color: Colors.white54)),
              const Text('HYOID',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2)),
              const SizedBox(height: 24),

              if (!_otpSent) ...[
                const Text(
                  'Enter Phone Number',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                IntlPhoneField(
                  controller: _phoneCtrl,
                  style: const TextStyle(color: Colors.white),
                  dropdownTextStyle: const TextStyle(color: Colors.white),
                  dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.darkSurface,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppTheme.borderCol)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: accent)),
                  ),
                  initialCountryCode: 'IN',
                  showCountryFlag: false, // Fix for asset loading errors on web
                  disableLengthCheck: false,
                  flagsButtonPadding: const EdgeInsets.only(left: 8),
                  onChanged: (phone) {
                    _completePhoneNumber = phone.completeNumber;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading && auth.status == AuthStatus.otpSending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Send OTP',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.borderCol)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child:
                          Text('OR', style: TextStyle(color: Colors.white54)),
                    ),
                    Expanded(child: Divider(color: AppTheme.borderCol)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _googleSignIn,
                    icon: isLoading && auth.status == AuthStatus.googleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.g_mobiledata,
                            color: Colors.white, size: 36),
                    label: const Text('Continue with Google',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.borderCol),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ] else ...[
                const Text('Enter OTP',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _otpCtrls[index],
                        focusNode: _otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppTheme.darkSurface,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppTheme.borderCol)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: accent)),
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty && index < 5) {
                            _otpFocusNodes[index + 1].requestFocus();
                          } else if (val.isNotEmpty && index == 5) {
                            // Auto-submit when last digit is entered
                            _verifyOtp();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Resend countdown / button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _resendCountdown > 0 ? null : _resendOtp,
                      child: Text(
                        _resendCountdown > 0
                            ? 'Resend OTP in ${_resendCountdown}s'
                            : 'Resend OTP',
                        style: TextStyle(
                          color: _resendCountdown > 0
                              ? Colors.white38
                              : accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading && auth.status == AuthStatus.otpVerifying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Verify & Login',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),
              ],

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New to Hyoid? ',
                      style: TextStyle(color: Colors.white54)),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen())),
                    child: Text('Register here',
                        style: TextStyle(
                            color: accent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
