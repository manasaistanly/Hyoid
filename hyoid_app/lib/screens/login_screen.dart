import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/screens/main_navigation_screen.dart';
import 'package:hyoid_app/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  bool _otpSent = false;
  bool _isLoading = false;

  void _sendOtp() {
    setState(() { _isLoading = true; });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
    });
  }

  void _verifyOtp() async {
    setState(() { _isLoading = true; });
    await Future.delayed(const Duration(seconds: 1));
    await _saveTokenAndNavigate();
  }

  void _googleSignIn() async {
    setState(() { _isLoading = true; });
    // Simulate google SDK auth hook latency
    await Future.delayed(const Duration(seconds: 1));
    await _saveTokenAndNavigate();
  }

  Future<void> _saveTokenAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', 'mock_token_123');
    
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (Route<dynamic> route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        leading: BackButton(color: Colors.white, onPressed: () => Navigator.pop(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome back to", style: TextStyle(fontSize: 20, color: Colors.white54)),
              const Text("HYOID", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
              const SizedBox(height: 30),
              
              if (!_otpSent) ...[
                const Text("Enter Phone Number", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone, color: AppTheme.orangeAccent),
                    filled: true,
                    fillColor: AppTheme.darkSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderCol)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.orangeAccent)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Send OTP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.borderCol)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("OR", style: TextStyle(color: Colors.white54)),
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
                    icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 36),
                    label: const Text("Continue with Google", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.borderCol),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                
              ] else ...[
                const Text("Enter OTP", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _otpCtrls[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppTheme.darkSurface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderCol)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.orangeAccent)),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 5) FocusScope.of(context).nextFocus();
                      },
                    ),
                  )),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Verify & Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
              
              const Spacer(),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text("New to Hyoid? ", style: TextStyle(color: Colors.white54)),
                   GestureDetector(
                     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                     child: const Text("Register here", style: TextStyle(color: AppTheme.orangeAccent, fontWeight: FontWeight.bold)),
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
