import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_prompt_sheet.dart';

class TrackAppointmentScreen extends StatefulWidget {
  const TrackAppointmentScreen({super.key});

  @override
  State<TrackAppointmentScreen> createState() => _TrackAppointmentScreenState();
}

class _TrackAppointmentScreenState extends State<TrackAppointmentScreen> {
  int _currentStep = 0;
  // ignore: unused_field
  GoogleMapController? _mapController;

  final List<Map<String, dynamic>> _steps = [
    {'title': 'Pending', 'color': Colors.amber, 'icon': Icons.hourglass_top},
    {'title': 'Contacted', 'color': Colors.blue, 'icon': Icons.phone_in_talk},
    {'title': 'Assigned', 'color': Colors.purple, 'icon': Icons.assignment_ind},
    {
      'title': 'Confirmed',
      'color': Colors.green,
      'icon': Icons.check_circle_outline,
    },
    {'title': 'Completed', 'color': Colors.grey, 'icon': Icons.done_all},
  ];

  // Coordinates for India map
  final LatLng _indiaCenter = const LatLng(20.5937, 78.9629);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isGuest) {
        Navigator.pop(context);
        showLoginPromptSheet(context, actionDescription: 'track your appointment');
      } else {
        _simulateTracking();
      }
    });

    // Add an initial marker
    _markers.add(
      Marker(
        markerId: const MarkerId('patient_location'),
        position: _indiaCenter,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );
  }

  void _simulateTracking() async {
    for (int i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      setState(() => _currentStep = i);
      // await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: Stack(
        children: [
          // Background Real-Time Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _indiaCenter,
              zoom: 4.5,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),

          // Back Button Overlay
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: AppTheme.darkSurface,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bottom Status Tracking Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.60,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
                border: Border.all(color: AppTheme.borderCol, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.pureBlack,
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Appointment Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(_steps.length, (index) {
                          final step = _steps[index];
                          final isActive = index <= _currentStep;
                          final isCurrent = index == _currentStep;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            margin: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isActive
                                            ? step['color'].withValues(
                                                alpha: 0.2,
                                              )
                                            : Colors.white10,
                                        border: Border.all(
                                          color: isActive
                                              ? step['color']
                                              : Colors.transparent,
                                        ),
                                        boxShadow: isCurrent
                                            ? [
                                                BoxShadow(
                                                  color: step['color']
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 10,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Icon(
                                        step['icon'],
                                        color: isActive
                                            ? step['color']
                                            : Colors.white24,
                                        size: 20,
                                      ),
                                    ),
                                    if (index < _steps.length - 1)
                                      Container(
                                        width: 2,
                                        height: 25,
                                        color: isActive
                                            ? step['color']
                                            : Colors.white10,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    step['title'],
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white38,
                                      fontSize: 16,
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
