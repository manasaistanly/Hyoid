import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import '../models/doctor_model.dart';
import '../services/consultation_service.dart';
import 'consultation_chat_screen.dart';

class BookingScreen extends StatefulWidget {
  final Doctor doctor;
  final String consultationType;

  const BookingScreen({
    super.key,
    required this.doctor,
    required this.consultationType,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedSlot;
  bool _isBooking = false;

  List<TimeSlot> get _availableSlots {
    // Filter slots for selected date
    return widget.doctor.availableSlots.where((slot) {
      return slot.dateTime.year == _selectedDate.year &&
             slot.dateTime.month == _selectedDate.month &&
             slot.dateTime.day == _selectedDate.day &&
             slot.isAvailable;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Book Appointment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E2E2E), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(widget.doctor.profileImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: widget.doctor.profileImage.isEmpty
                        ? Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.orangeAccent,
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 25),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${widget.doctor.name}',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          widget.doctor.specialization,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.orangeAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.consultationType.toUpperCase(),
                      style: const TextStyle(color: AppTheme.orangeAccent, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Date Picker
            const Text(
              'Select Date',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E2E2E), width: 1.5),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                    _selectedSlot = null; // Reset slot selection
                  });
                },
                currentDate: _selectedDate,
              ),
            ),

            const SizedBox(height: 24),

            // Time Slots
            const Text(
              'Available Time Slots',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _availableSlots.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2E2E2E), width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        'No available slots for this date',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableSlots.map((slot) {
                      final isSelected = _selectedSlot == slot;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSlot = slot),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.orangeAccent : AppTheme.darkSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.orangeAccent : const Color(0xFF2E2E2E),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '${slot.dateTime.hour.toString().padLeft(2, '0')}:${slot.dateTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 24),

            // Instant Consultation Option
            if (widget.doctor.availabilityStatus == 'available')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Consult Now',
                            style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const Text(
                            'Doctor is available for instant consultation',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _consultNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Start Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Booking Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E2E2E), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Consultation Fee', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      Text('₹${widget.doctor.consultationFee}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFF2E2E2E)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('₹${widget.doctor.consultationFee}', style: const TextStyle(color: AppTheme.orangeAccent, fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Book Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedSlot != null && !_isBooking ? _bookAppointment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
                child: _isBooking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Confirm Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _bookAppointment() async {
    if (_selectedSlot == null) return;

    setState(() => _isBooking = true);

    try {
      // TODO: Get actual patient ID from auth
      const patientId = 'patient_123';

      final appointment = await ConsultationService.createAppointment(
        doctorId: widget.doctor.id,
        patientId: patientId,
        scheduledAt: _selectedSlot!.dateTime,
        type: widget.consultationType,
      );

      if (!mounted) return;

      // Navigate to consultation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConsultationChatScreen(
            appointment: appointment,
            doctor: widget.doctor,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $e')),
      );
    }
  }

  void _consultNow() {
    // TODO: Implement instant consultation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Instant consultation feature coming soon!')),
    );
  }
}