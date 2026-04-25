import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart';
import 'package:dio/dio.dart';
import 'package:hyoid_app/core/constants/api_constants.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  State<DoctorRegistrationScreen> createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _specialtyCtrl = TextEditingController();
  final TextEditingController _licenseCtrl = TextEditingController();
  final TextEditingController _expCtrl = TextEditingController();
  final TextEditingController _feeCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();
  
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
        'role': 'doctor',
        'name': _nameCtrl.text,
        'phone': _phoneCtrl.text,
        'specialty': _specialtyCtrl.text,
        'licenseNumber': _licenseCtrl.text,
        'experienceYears': int.tryParse(_expCtrl.text) ?? 0,
        'consultationFee': int.tryParse(_feeCtrl.text) ?? 0,
        'bio': _bioCtrl.text,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token'] ?? '');
        await prefs.setString('user_role', 'doctor');
        await prefs.setString('user_id', data['user']['id']?.toString() ?? '');
        
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => DoctorShell()),
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
        title: const Text("Doctor Onboarding", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.darkSurface,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, kDoctorBlue.withValues(alpha: 0.5), Colors.transparent],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text("Join our Network", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text("Provide your professional details to start receiving consultation requests.", style: TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 32),
            
            _buildInputField("Full Name (with Dr. prefix)", _nameCtrl, Icons.person_rounded, TextInputType.name),
            _buildInputField("Contact Number", _phoneCtrl, Icons.phone_rounded, TextInputType.phone),
            _buildInputField("Specialization (e.g. Cardiologist)", _specialtyCtrl, Icons.medical_services_rounded, TextInputType.text),
            _buildInputField("Medical License Number", _licenseCtrl, Icons.verified_user_rounded, TextInputType.text),
            
            Row(
              children: [
                Expanded(child: _buildInputField("Experience (Years)", _expCtrl, Icons.timer_rounded, TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField("Consultation Fee (₹)", _feeCtrl, Icons.payments_rounded, TextInputType.number)),
              ],
            ),
            
            _buildInputField("Short Bio / Expertise", _bioCtrl, Icons.description_rounded, TextInputType.multiline, maxLines: 4),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kDoctorBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kDoctorBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: kDoctorBlue, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Our team will verify your license before you can start accepting bookings.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDoctorBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: kDoctorBlue.withValues(alpha: 0.4),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Register as Doctor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, TextInputType type, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
          prefixIcon: Icon(icon, color: kDoctorBlue, size: 22),
          filled: true,
          fillColor: AppTheme.darkSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), 
            borderSide: const BorderSide(color: AppTheme.borderCol, width: 1.5)
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), 
            borderSide: const BorderSide(color: AppTheme.borderCol, width: 1.5)
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), 
            borderSide: const BorderSide(color: kDoctorBlue, width: 1.5)
          ),
        ),
      ),
    );
  }
}
