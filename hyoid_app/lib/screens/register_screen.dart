import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/screens/main_navigation_screen.dart';
import 'package:hyoid_app/models/user_profile_model.dart';
import 'package:hyoid_app/services/user_service.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  final TextEditingController _bloodCtrl = TextEditingController();
  final TextEditingController _emergencyCtrl = TextEditingController();
  
  bool _isLoading = false;
  String _completePhoneNumber = '';
  String _completeEmergencyNumber = '';

  void _submitRegistration() async {
    setState(() { _isLoading = true; });
    
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    
    final phoneToSave = _completePhoneNumber.isNotEmpty ? _completePhoneNumber : '+91${_phoneCtrl.text.trim()}';
    final emergencyToSave = _completeEmergencyNumber.isNotEmpty ? _completeEmergencyNumber : '+91${_emergencyCtrl.text.trim()}';

    await prefs.setString('jwt_token', 'mock_token_register_456');
    await prefs.setString('user_role', 'patient');
    await prefs.setString('user_phone', phoneToSave);
    await prefs.setString('user_name', _nameCtrl.text.trim());
    
    final rawPhone = _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    final idSuffix = rawPhone.isNotEmpty ? rawPhone.substring(rawPhone.length - 4) : DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    await prefs.setString('user_id', 'HY-$idSuffix');

    await UserService.saveProfile(UserProfile(
      userId: prefs.getString('user_id') ?? 'HY-0000',
      name: _nameCtrl.text.trim(),
      phone: phoneToSave,
      email: '',
      dob: _dobCtrl.text.trim(),
      bloodGroup: _bloodCtrl.text.trim(),
      emergencyContact: emergencyToSave,
      role: 'patient',
    ));

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
        title: const Text("Create Account", style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.darkSurface,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
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
            const Text("Provide Full Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text("This info speeds up emergency triage.", style: TextStyle(color: AppTheme.orangeAccent)),
            const SizedBox(height: 30),
            
            _buildInputField("Full Name", _nameCtrl, Icons.person, TextInputType.name),
            _buildPhoneField("Phone Number", _phoneCtrl, isEmergency: false),
            _buildInputField("Date of Birth", _dobCtrl, Icons.calendar_today, TextInputType.datetime),
            _buildInputField("Blood Group", _bloodCtrl, Icons.bloodtype, TextInputType.text),
            _buildPhoneField("Emergency Contact", _emergencyCtrl, isEmergency: true),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Register & Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: AppTheme.orangeAccent),
          filled: true,
          fillColor: AppTheme.darkSurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderCol)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.orangeAccent)),
        ),
      ),
    );
  }

  Widget _buildPhoneField(String label, TextEditingController controller, {required bool isEmergency}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: IntlPhoneField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        dropdownTextStyle: const TextStyle(color: Colors.white),
        dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: AppTheme.darkSurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderCol)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.orangeAccent)),
        ),
        initialCountryCode: 'IN', // Default to India as per previous +91
        showCountryFlag: false, // Fix for asset loading errors on web
        flagsButtonPadding: const EdgeInsets.only(left: 8),
        onChanged: (phone) {
          if (isEmergency) {
            _completeEmergencyNumber = phone.completeNumber;
          } else {
            _completePhoneNumber = phone.completeNumber;
          }
        },
      ),
    );
  }
}
