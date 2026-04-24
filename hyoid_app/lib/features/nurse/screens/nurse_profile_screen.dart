import 'package:flutter/material.dart';
import '../../../models/nurse_model.dart';
import 'nurse_booking_flow_screen.dart';

class NurseProfileScreen extends StatelessWidget {
  final Nurse nurse;

  const NurseProfileScreen({super.key, required this.nurse});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nurse.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    'assets/images/nurse_placeholder.png',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            nurse.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (nurse.verified)
                            Icon(Icons.verified, color: Colors.blue),
                        ],
                      ),
                      Text('${nurse.experience} years experience'),
                      Text('Languages: ${nurse.languages.join(', ')}'),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          Text(
                            '${nurse.rating} (${nurse.reviewCount} reviews)',
                          ),
                        ],
                      ),
                      Text('₹${nurse.hourlyRate}/hour'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Qualifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...nurse.qualifications.map((qual) => Text('• $qual')),
            SizedBox(height: 20),
            Text(
              'Specializations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...nurse.specializations.map((spec) => Text('• $spec')),
            SizedBox(height: 20),
            Text(
              'Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Placeholder for reviews
            Text('No reviews yet'),
            SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NurseBookingFlowScreen(nurse: nurse),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('Book Now'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NurseBookingFlowScreen(
                          nurse: nurse,
                          isScheduled: true,
                        ),
                      ),
                    ),
                    child: Text('Schedule Later'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
