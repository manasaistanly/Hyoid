import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import 'track_appointment_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_prompt_sheet.dart';
import '../providers/user_provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String type; // 'doctor' or 'nurse'

  const BookAppointmentScreen({super.key, required this.type});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _symptomsController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isUrgent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Auto-fill patient details from UserProvider
    final user = context.read<UserProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _ageController.text = user.age?.toString() ?? '';
      _contactController.text = user.phone ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isGuest) {
        Navigator.pop(context);
        showLoginPromptSheet(context, actionDescription: 'book an appointment');
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final appointment = AppointmentModel(
      userId: context.read<AuthProvider>().currentUser?.id ?? 'user123',
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? 0,
      contact: _contactController.text,
      symptoms: _symptomsController.text,
      status: 'pending',
      type: widget.type,
      preferredTime:
          '${_selectedDate!.toIso8601String().split('T')[0]} ${_selectedTime!.format(context)}',
      priority: _isUrgent ? 'urgent' : 'normal',
    );

    try {
      final provider = AppointmentProvider();
      final success = await provider.bookAppointment(appointment);

      setState(() => _isLoading = false);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TrackAppointmentScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.error?.toString() ?? 'Error booking appointment',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleType = widget.type == 'doctor' ? 'Doctor' : 'Nurse';

    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        title: Text(
          'Book a $titleType Appointment',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.darkSurface,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.orangeAccent),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Patient Details'),
                    _buildTextField(_nameController, 'Full Name'),
                    _buildTextField(_ageController, 'Age', isNumber: true),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: IntlPhoneField(
                        controller: _contactController,
                        style: const TextStyle(color: Colors.white),
                        dropdownTextStyle: const TextStyle(color: Colors.white),
                        dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Contact Number',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: AppTheme.darkSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        initialCountryCode: 'IN',
                        showCountryFlag: false, // Fix for asset loading errors on web
                        flagsButtonPadding: const EdgeInsets.only(left: 8),
                        onChanged: (phone) {},
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionHeader('Symptoms & Notes'),
                    _buildTextField(
                      _symptomsController,
                      'Describe your symptoms',
                      maxLines: 3,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.mic, color: Colors.white54),
                        onPressed: () {
                          // TODO: Implement Speech-to-text
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Voice input coming soon!'),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionHeader('Preferred Schedule'),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 30),
                                ),
                              );
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            },
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.white54,
                            ),
                            label: Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() => _selectedTime = time);
                              }
                            },
                            icon: const Icon(
                              Icons.access_time,
                              color: Colors.white54,
                            ),
                            label: Text(
                              _selectedTime == null
                                  ? 'Select Time'
                                  : _selectedTime!.format(context),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    _buildSectionHeader('Priority'),
                    SwitchListTile(
                      title: const Text(
                        'Mark as Urgent',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Priority assignment may cost extra',
                        style: TextStyle(color: Colors.white54),
                      ),
                      activeThumbColor: Colors.redAccent,
                      value: _isUrgent,
                      onChanged: (val) => setState(() => _isUrgent = val),
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        onPressed: _submit,
                        child: const Text(
                          'Submit Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: AppTheme.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon,
        ),
        validator: (value) => value!.isEmpty ? 'Required field' : null,
      ),
    );
  }
}
