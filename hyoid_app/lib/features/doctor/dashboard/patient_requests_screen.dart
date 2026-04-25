import 'package:flutter/material.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart' show kDoctorBlue;
import 'package:hyoid_app/features/doctor/data/services/doctor_api_service.dart';
import 'package:hyoid_app/features/doctor/data/models/doctor_request.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/doctor/dashboard/patient_details_screen.dart';
import 'package:intl/intl.dart';

class PatientRequestsScreen extends StatefulWidget {
  const PatientRequestsScreen({super.key});

  @override
  State<PatientRequestsScreen> createState() => _PatientRequestsScreenState();
}

class _PatientRequestsScreenState extends State<PatientRequestsScreen> {
  final DoctorApiService _apiService = DoctorApiService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color(0xFF151515),
          elevation: 0,
          title: const Text('Consultations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: kDoctorBlue,
            labelColor: kDoctorBlue,
            unselectedLabelColor: Colors.white38,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestList('pending'),
            _buildRequestList('accepted'),
            _buildRequestList('completed'), // Note: In a real app, completed might go to history
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(String status) {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      color: kDoctorBlue,
      child: FutureBuilder<List<DoctorRequest>>(
        future: status == 'completed' 
            ? _apiService.getHistory() 
            : _apiService.getRequests(status: status),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kDoctorBlue));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return _buildEmptyState(status);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _buildRequestCard(requests[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message = "No $status requests";
    IconData icon = Icons.inbox_rounded;
    if (status == 'pending') message = "All caught up! No pending requests.";
    if (status == 'accepted') message = "No active consultations currently.";
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white10, size: 64),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white38, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(DoctorRequest request) {
    final bool isEmergency = request.priority == RequestPriority.emergency;
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => PatientDetailsScreen(consultationId: request.id))
      ).then((_) => setState(() {})),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isEmergency ? AppTheme.dangerRed.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: kDoctorBlue.withValues(alpha: 0.1),
                  child: const Icon(Icons.person_outline_rounded, color: kDoctorBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.patientName, 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Age ${request.age}', 
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                    ],
                  ),
                ),
                if (isEmergency)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('EMERGENCY', 
                        style: TextStyle(color: AppTheme.dangerRed, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(request.symptoms, 
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: Colors.white.withValues(alpha: 0.3), size: 14),
                    const SizedBox(width: 4),
                    Text(DateFormat('hh:mm a').format(request.time), 
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
                  ],
                ),
                if (request.status == RequestStatus.pending)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _handleReject(request.id),
                        child: const Text('Reject', style: TextStyle(color: AppTheme.dangerRed)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _handleAccept(request.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDoctorBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text('Accept'),
                      ),
                    ],
                  )
                else
                  Text(request.status.name.toUpperCase(), 
                      style: TextStyle(color: kDoctorBlue.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAccept(String id) async {
    final success = await _apiService.acceptRequest(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consultation accepted')));
      setState(() {});
    }
  }

  void _handleReject(String id) async {
    final success = await _apiService.rejectRequest(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consultation rejected')));
      setState(() {});
    }
  }
}
