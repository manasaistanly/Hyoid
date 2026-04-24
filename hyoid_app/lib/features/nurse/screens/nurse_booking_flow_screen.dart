import 'package:flutter/material.dart';
import '../../../models/nurse_model.dart';
import '../../../services/nurse_service.dart';
import '../../../services/user_service.dart';
import '../../../models/user_model.dart';

class NurseBookingFlowScreen extends StatefulWidget {
  final Nurse nurse;
  final bool isScheduled;

  const NurseBookingFlowScreen({
    super.key,
    required this.nurse,
    this.isScheduled = false,
  });

  @override
  _NurseBookingFlowScreenState createState() => _NurseBookingFlowScreenState();
}

class _NurseBookingFlowScreenState extends State<NurseBookingFlowScreen> {
  int currentStep = 0;
  String selectedService = '';
  DateTime selectedDate = DateTime.now();
  String selectedTime = '';
  int duration = 1;
  String notes = '';

  final List<String> services = [
    'injection',
    'wound care',
    'elderly care',
    'post-surgery care',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Nurse')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Step ${currentStep + 1} of 4',
              style: TextStyle(fontSize: 16),
            ),
            LinearProgressIndicator(value: (currentStep + 1) / 4),
            SizedBox(height: 20),
            Expanded(child: _buildCurrentStep()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => currentStep--),
                    child: Text('Back'),
                  )
                else
                  SizedBox(),
                ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(currentStep == 3 ? 'Confirm Booking' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildServiceSelection();
      case 1:
        return _buildDateTimeSelection();
      case 2:
        return _buildDurationSelection();
      case 3:
        return _buildNotesAndConfirm();
      default:
        return Container();
    }
  }

  Widget _buildServiceSelection() {
    return Column(
      children: services.map((service) {
        return RadioListTile<String>(
          title: Text(service),
          value: service,
          groupValue: selectedService,
          onChanged: (value) => setState(() => selectedService = value!),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      children: [
        Text('Select Date'),
        CalendarDatePicker(
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 30)),
          onDateChanged: (date) => setState(() => selectedDate = date),
        ),
        Text('Select Time'),
        DropdownButton<String>(
          value: selectedTime.isNotEmpty ? selectedTime : null,
          hint: Text('Choose time'),
          items: ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00']
              .map((time) => DropdownMenuItem(value: time, child: Text(time)))
              .toList(),
          onChanged: (value) => setState(() => selectedTime = value!),
        ),
      ],
    );
  }

  Widget _buildDurationSelection() {
    return Column(
      children: [
        Text('Duration (hours)'),
        Slider(
          value: duration.toDouble(),
          min: 1,
          max: 8,
          divisions: 7,
          label: '$duration hours',
          onChanged: (value) => setState(() => duration = value.toInt()),
        ),
        Text(
          'Total: ₹${(widget.nurse.hourlyRate * duration).toStringAsFixed(2)}',
        ),
      ],
    );
  }

  Widget _buildNotesAndConfirm() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Additional Notes (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) => notes = value,
        ),
        SizedBox(height: 20),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Booking Summary',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Service: $selectedService'),
                Text('Date: ${selectedDate.toLocal()}'),
                Text('Time: $selectedTime'),
                Text('Duration: $duration hours'),
                Text(
                  'Total: ₹${(widget.nurse.hourlyRate * duration).toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _nextStep() async {
    if (currentStep < 3) {
      setState(() => currentStep++);
    } else {
      // Confirm booking
      try {
        // Load user profile to get user ID
        UserModel user = await UserService().getProfile();
        if (user.id.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please login to book a nurse')),
          );
          return;
        }

        final bookingData = {
          'userId': user.id,
          'nurseId': widget.nurse.id,
          'serviceType': selectedService,
          'date': selectedDate.toIso8601String(),
          'time': selectedTime,
          'duration': duration,
          'notes': notes,
          'location': {
            'address': 'User address',
            'coordinates': [0.0, 0.0],
          }, // Get user location
          'payment': {
            'amount': widget.nurse.hourlyRate * duration,
            'status': 'pending',
          },
        };

        await NurseService.createBooking(bookingData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking confirmed!')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
      }
    }
  }
}
