import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import '../../../services/appointment_provider.dart';
import '../../../services/user_service.dart';
import 'track_appointment_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

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
  String _selectedType = 'doctor';
  String _selectedPriority = 'normal';

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  Future<void> _prefillUserData() async {
    final user = await UserService.loadProfile();
    if (user.userId.isNotEmpty || user.hasDetails) {
      setState(() {
        _nameController.text = user.name;
        _contactController.text = user.phone;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.orangeAccent,
              onPrimary: Colors.white,
              surface: AppTheme.darkSurface,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppTheme.pureBlack),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.orangeAccent,
              onPrimary: Colors.white,
              surface: AppTheme.darkSurface,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppTheme.pureBlack),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your preferred date and time.'),
          ),
        );
        return;
      }

      final preferredDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final data = {
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'contact': _contactController.text.trim(),
        'symptoms': _symptomsController.text.trim(),
        'type': _selectedType,
        'preferred_time': preferredDateTime.toIso8601String(),
        'priority': _selectedPriority,
        'status': 'pending',
      };

      final newAppointment = await AppointmentProvider.instance
          .submitAppointment(data);

      if (mounted) {
        if (newAppointment != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment requested successfully!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TrackAppointmentScreen(appointment: newAppointment),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppointmentProvider.instance.errorMessage ??
                    'Failed to submit request.',
              ),
              backgroundColor: AppTheme.dangerRed,
            ),
          );
        }
      }
    }
  }

  // Optional: Speech-to-text plugin integration stub
  /*
  void _startListening() async {
    // Implement speech to text
    // E.g. bool available = await speech.initialize();
    // if (available) { speech.listen(onResult: (val) => setState(() => _symptomsController.text = val.recognizedWords)); }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: AppTheme.darkSurface,
      ),
      body: ListenableBuilder(
        listenable: AppointmentProvider.instance,
        builder: (context, _) {
          final isLoading = AppointmentProvider.instance.isLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Managed Care',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A triage admin will assign the best professional based on your symptoms.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Patient Details
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          'Patient Name',
                          Icons.person_outline,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _ageController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                'Age',
                                Icons.cake_outlined,
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _contactController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration(
                                'Contact Number',
                                Icons.phone_outlined,
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Service Details
                      const Text(
                        'Service Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSelectionCard(
                              label: 'Doctor',
                              icon: Icons.local_hospital_outlined,
                              isSelected: _selectedType == 'doctor',
                              onTap: () =>
                                  setState(() => _selectedType = 'doctor'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSelectionCard(
                              label: 'Nurse',
                              icon: Icons.medication_outlined,
                              isSelected: _selectedType == 'nurse',
                              onTap: () =>
                                  setState(() => _selectedType = 'nurse'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _symptomsController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 4,
                        decoration:
                            _inputDecoration(
                              'Symptoms / Reason for visit',
                              Icons.description_outlined,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.mic_none_outlined,
                                  color: AppTheme.orangeAccent,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Voice input coming soon!'),
                                    ),
                                  );
                                  // _startListening(); // Stub for voice
                                },
                              ),
                            ),
                        validator: (value) => value!.isEmpty
                            ? 'Please describe your symptoms'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Scheduling
                      const Text(
                        'Preferred Schedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.borderCol),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color: AppTheme.orangeAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedDate == null
                                            ? 'Select Date'
                                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                        style: TextStyle(
                                          color: _selectedDate == null
                                              ? Colors.white54
                                              : Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.borderCol),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: AppTheme.orangeAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedTime == null
                                            ? 'Select Time'
                                            : _selectedTime!.format(context),
                                        style: TextStyle(
                                          color: _selectedTime == null
                                              ? Colors.white54
                                              : Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Priority
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderCol),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Urgent Priority',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Faster triage for severe symptoms',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _selectedPriority == 'urgent',
                              activeThumbColor: AppTheme.dangerRed,
                              onChanged: (val) {
                                setState(() {
                                  _selectedPriority = val ? 'urgent' : 'normal';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.orangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Request Appointment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.orangeAccent,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
      prefixIcon: Icon(
        icon,
        color: AppTheme.orangeAccent.withValues(alpha: 0.7),
      ),
      filled: true,
      fillColor: AppTheme.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.borderCol),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.borderCol),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.orangeAccent),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.orangeAccent.withValues(alpha: 0.15)
              : AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.orangeAccent : AppTheme.borderCol,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.orangeAccent : Colors.white54,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.orangeAccent : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
