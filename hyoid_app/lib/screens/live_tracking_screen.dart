import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/globals.dart';
import 'package:hyoid_app/models/service_model.dart';
import 'package:hyoid_app/models/lab_test_model.dart';
import 'package:hyoid_app/screens/lab_report_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final ServiceBooking booking;
  const LiveTrackingScreen({super.key, required this.booking});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _reportTimer;
  bool _reportReady = false;
  LabReport? _currentReport;

  bool get _isLabBooking => widget.booking.title == 'Doorstep Lab Test';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 2)
    )..repeat(reverse: true);

    if (_isLabBooking) {
      _currentReport = globalLabReports.value.isNotEmpty ? globalLabReports.value.first : null;
      _reportTimer = Timer(const Duration(seconds: 8), () {
        if (!mounted) return;
        final reports = globalLabReports.value;
        if (reports.isNotEmpty) {
          final report = reports.first;
          final updatedReport = report.copyWith(status: 'Report ready');
          globalLabReports.value = [updatedReport, ...reports.where((element) => element.id != report.id)];
          setState(() {
            _currentReport = updatedReport;
            _reportReady = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _reportTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: Stack(
        children: [
          // Simulated Map Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.network(
                "https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800&auto=format&fit=crop",
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.darken,
                color: AppTheme.pureBlack.withValues(alpha: 0.6),
              ),
            ),
          ),
          
          // Animated Location Marker Point
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.45,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 50 + (_pulseController.value * 40),
                      height: 50 + (_pulseController.value * 40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.booking.color.withValues(alpha: 0.3 - (_pulseController.value * 0.2)),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: widget.booking.color,
                      radius: 14,
                      child: Icon(widget.booking.icon, color: Colors.white, size: 16),
                    )
                  ],
                );
              }
            ),
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
          
          // Bottom Delivery tracking Panel (Swiggy/Zomato style)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                border: Border.all(color: AppTheme.borderCol, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: AppTheme.pureBlack, blurRadius: 40, spreadRadius: 10)
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 60, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Arriving in", style: TextStyle(color: Colors.white54, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text("14 mins", style: TextStyle(color: widget.booking.color, fontSize: 36, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.15), 
                          borderRadius: BorderRadius.circular(20), 
                          border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3))
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.directions_car, color: AppTheme.successGreen, size: 16),
                            SizedBox(width: 6),
                            Text("On the way", style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Live Progress Tracker Timeline
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.pureBlack.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressStep("Booking Confirmed", "10:30 AM", true, false),
                        _buildProgressStep("Provider Assigned", "10:35 AM", true, false),
                        _buildProgressStep("On the Way", "Expected 11:00 AM", !_reportReady, !_reportReady),
                        _buildProgressStep(
                          _reportReady ? "Report Ready" : "Service Started",
                          _reportReady ? "Tap to view your report" : "Pending",
                          _reportReady,
                          _reportReady,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: widget.booking.color.withValues(alpha: 0.1),
                        child: Icon(widget.booking.icon, color: widget.booking.color, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.booking.providerName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(widget.booking.specialization, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: AppTheme.successGreen.withValues(alpha: 0.15),
                        child: IconButton(icon: const Icon(Icons.call, color: AppTheme.successGreen), onPressed: (){}),
                      ),
                    ],
                  ),
                  
                  if (_isLabBooking && _reportReady)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            final report = globalLabReports.value.isNotEmpty ? globalLabReports.value.first : null;
                            if (report != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => LabReportScreen(report: report)));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.orangeAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('View Test Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => _handleCancelService(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.dangerRed, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                      ),
                      child: const Text("Cancel Service", style: TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      )
    );
  }

  Widget _buildProgressStep(String title, String subtitle, bool isCompleted, bool isCurrent, {bool isLast = false}) {
    Color nodeColor = isCompleted ? AppTheme.successGreen : Colors.white24;
    Color lineColor = isCompleted && !isCurrent ? AppTheme.successGreen : Colors.white12;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent ? AppTheme.orangeAccent : nodeColor,
                border: isCurrent ? Border.all(color: AppTheme.orangeAccent.withValues(alpha: 0.4), width: 4) : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28, // Height of the connecting line between nodes
                color: lineColor,
              )
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: TextStyle(
                color: isCurrent ? AppTheme.orangeAccent : (isCompleted ? Colors.white : Colors.white54), 
                fontWeight: isCompleted || isCurrent ? FontWeight.bold : FontWeight.normal, 
                fontSize: 16
              )
            ),
            const SizedBox(height: 2),
            Text(
              subtitle, 
              style: TextStyle(color: isCurrent ? Colors.white70 : Colors.white38, fontSize: 12)
            ),
          ],
        )
      ],
    );
  }

  void _handleCancelService(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.borderCol)),
          title: Row(
            children: const [
              Icon(Icons.warning_rounded, color: AppTheme.dangerRed),
              SizedBox(width: 8),
              Text("Cancel Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: const Text(
            "Are you sure you want to cancel this requested service? The assigned technician will be notified instantly.", 
            style: TextStyle(color: Colors.white70, fontSize: 15)
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("No, Keep it", style: TextStyle(color: Colors.white54, fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                globalHasActiveBooking.value = false;
                Navigator.pop(dialogContext); // Drop the modal
                Navigator.pop(context); // Pop tracking screen out
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Service cancelled successfully."),
                    backgroundColor: AppTheme.dangerRed,
                    behavior: SnackBarBehavior.floating,
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }
}
