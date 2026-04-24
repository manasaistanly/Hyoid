import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../models/nurse_booking_model.dart';

class NurseTrackingScreen extends StatefulWidget {
  final NurseBooking booking;

  const NurseTrackingScreen({super.key, required this.booking});

  @override
  _NurseTrackingScreenState createState() => _NurseTrackingScreenState();
}

class _NurseTrackingScreenState extends State<NurseTrackingScreen> {
  late IO.Socket socket;
  String currentStatus = 'assigned';
  Map<String, dynamic>? nurseLocation;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();

    socket.on('connect', (_) {
      socket.emit('join-booking', widget.booking.id);
    });

    socket.on('nurse-location-update', (data) {
      setState(() {
        nurseLocation = data['location'];
        currentStatus = data['status'];
      });
    });

    socket.on('booking-status-update', (data) {
      setState(() => currentStatus = data['status']);
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nurse Tracking')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Status: ${currentStatus.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (nurseLocation != null)
                      Text(
                        'Location: ${nurseLocation!['coordinates'].join(', ')}',
                      ),
                    // Placeholder for map
                    Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(child: Text('Map Placeholder')),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showChat(),
              child: Text('Chat with Nurse'),
            ),
            ElevatedButton(
              onPressed: () => _callNurse(),
              child: Text('Call Nurse'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChat() {
    // Implement chat screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Chat feature coming soon')));
  }

  void _callNurse() {
    // Implement call functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Call feature coming soon')));
  }
}
