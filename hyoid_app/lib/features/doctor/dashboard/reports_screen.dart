import 'package:flutter/material.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart' show kDoctorBlue;
import 'package:hyoid_app/features/doctor/data/services/doctor_api_service.dart';
import 'package:hyoid_app/features/doctor/data/models/doctor_request.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DoctorApiService _apiService = DoctorApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151515),
        elevation: 0,
        title: const Text('Lab & Clinical Reports', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        color: kDoctorBlue,
        child: FutureBuilder<List<DoctorRequest>>(
          // For reports, we might want to see cases that have lab results or hospital referrals
          future: _apiService.getRequests(status: 'lab_requested'), 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: kDoctorBlue));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }
            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                return _buildReportTile(reports[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_rounded, color: Colors.white10, size: 64),
          const SizedBox(height: 16),
          const Text('No pending lab reports to review.', style: TextStyle(color: Colors.white38, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildReportTile(DoctorRequest report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kDoctorBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.biotech_rounded, color: kDoctorBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.patientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Lab: ${report.symptoms}', // In a real app, use report.labTests.join(', ')
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateFormat('MMM dd').format(report.time), 
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
              const SizedBox(height: 4),
              const Text('Awaiting Result', style: TextStyle(color: kDoctorBlue, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
