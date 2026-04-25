import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/patient/presentation/screens/main_navigation_screen.dart';
import 'package:hyoid_app/features/auth/presentation/screens/register_screen.dart';
import 'package:hyoid_app/features/auth/presentation/screens/doctor_registration_screen.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart';
import 'package:dio/dio.dart';
import 'package:hyoid_app/core/constants/api_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  bool _otpSent = false;
  bool _isLoading = false;
  String _selectedRole = 'patient'; // 'patient' | 'doctor'

  void _sendOtp() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
    });
  }

  void _verifyOtp() async {
    setState(() => _isLoading = true);
    try {
      final response = await Dio().post('${ApiConstants.baseUrl}/auth/verify-otp', data: {
        'phone': _phoneCtrl.text,
        'otp': _otpCtrls.map((c) => c.text).join(),
        'role': _selectedRole,
      });
      if (response.statusCode == 200) {
        if (response.data['isNewUser'] == true) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _selectedRole == 'doctor'
                  ? const DoctorRegistrationScreen()
                  : const RegisterScreen(),
              settings: RouteSettings(arguments: _phoneCtrl.text),
            ),
          );
        } else {
          await _saveTokenAndNavigate(response.data);
        }
      }
    } catch (e) {
      String errorMsg = 'Connection error';
      if (e is DioException) {
        errorMsg = e.message ?? 'Unknown error';
        if (e.response != null) {
          errorMsg = e.response?.data['message'] ?? e.response?.data['error'] ?? 'Error ${e.response?.statusCode}';
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final response = await Dio().post('${ApiConstants.baseUrl}/auth/google', data: {
        'email': 'mock@google.com',
        'role': _selectedRole,
        'name': 'Google User',
      });
      if (response.statusCode == 200) {
        await _saveTokenAndNavigate(response.data);
      }
    } catch (e) {
      String errorMsg = 'Google Sign-In failed';
      if (e is DioException && e.response != null) {
        errorMsg = e.response?.data['message'] ?? e.response?.data['error'] ?? 'Error ${e.response?.statusCode}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTokenAndNavigate(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = response['token'] ?? '';
    final Map<String, dynamic> user = response['user'] ?? {};
    final String role = (user['role'] as String?)?.toLowerCase() ?? 'patient';
    final String userId = user['id']?.toString() ?? '';

    await prefs.setString('jwt_token', token);
    await prefs.setString('user_role', role);
    await prefs.setString('user_id', userId);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => role == 'doctor'
            ? DoctorShell()
            : const MainNavigationScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = _selectedRole == 'doctor';
    final accent = isDoctor ? const Color(0xFF60A5FA) : AppTheme.orangeAccent;

    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        leading: BackButton(
            color: Colors.white, onPressed: () => Navigator.pop(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back to',
                    style: TextStyle(fontSize: 20, color: Colors.white54)),
                const Text('HYOID',
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2)),
                const SizedBox(height: 24),

                // ── Role Toggle ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Row(
                    children: ['patient', 'doctor'].map((role) {
                      final isActive = _selectedRole == role;
                      final roleAccent = role == 'doctor'
                          ? const Color(0xFF60A5FA)
                          : AppTheme.orangeAccent;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedRole = role;
                            _otpSent = false;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? roleAccent.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: isActive
                                  ? Border.all(
                                      color: roleAccent.withValues(alpha: 0.5),
                                      width: 1.5)
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  role == 'doctor'
                                      ? Icons.medical_services_rounded
                                      : Icons.person_rounded,
                                  color: isActive ? roleAccent : Colors.white38,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  role == 'doctor' ? 'Doctor' : 'Patient',
                                  style: TextStyle(
                                    color: isActive ? roleAccent : Colors.white38,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                if (!_otpSent) ...[
                  Text(
                    _selectedRole == 'doctor'
                        ? 'Doctor Phone Number'
                        : 'Enter Phone Number',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: accent),
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
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isLoading
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
                      onPressed: _isLoading ? null : _googleSignIn,
                      icon: const Icon(Icons.g_mobiledata,
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
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Verify & Login',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('New to Hyoid? ',
                        style: TextStyle(color: Colors.white54)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => _selectedRole == 'doctor'
                                  ? const DoctorRegistrationScreen()
                                  : const RegisterScreen())),
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
      ),
    );
  }
}
