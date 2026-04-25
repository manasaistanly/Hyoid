import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/patient/presentation/screens/main_navigation_screen.dart';
import 'package:dio/dio.dart';
import 'package:hyoid_app/core/constants/api_constants.dart';

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
  
  String? _phone;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _phone ??= ModalRoute.of(context)?.settings.arguments as String?;
    if (_phone != null && _phoneCtrl.text.isEmpty) {
      _phoneCtrl.text = _phone!;
    }
  }

  void _submitRegistration() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Phone are required')),
      );
      return;
    }

    setState(() { _isLoading = true; });
    
    try {
      final response = await Dio().post('${ApiConstants.baseUrl}/auth/register', data: {
        'role': 'patient',
        'name': _nameCtrl.text,
        'phone': _phoneCtrl.text,
        'dob': _dobCtrl.text,
        'bloodGroup': _bloodCtrl.text,
        'emergencyContact': _emergencyCtrl.text,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token'] ?? '');
        await prefs.setString('user_role', 'patient');
        await prefs.setString('user_id', data['user']['id']?.toString() ?? '');
        
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (Route<dynamic> route) => false
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
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
            const Text("Provide Full Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text("This info speeds up emergency triage.", style: TextStyle(color: AppTheme.orangeAccent)),
            const SizedBox(height: 30),
            
            _buildInputField("Full Name", _nameCtrl, Icons.person, TextInputType.name),
            _buildInputField("Phone Number", _phoneCtrl, Icons.phone, TextInputType.phone),
            _buildInputField("Date of Birth", _dobCtrl, Icons.calendar_today, TextInputType.datetime),
            _buildInputField("Blood Group", _bloodCtrl, Icons.bloodtype, TextInputType.text),
            _buildInputField("Emergency Contact", _emergencyCtrl, Icons.warning_amber_rounded, TextInputType.phone),
            
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
}
