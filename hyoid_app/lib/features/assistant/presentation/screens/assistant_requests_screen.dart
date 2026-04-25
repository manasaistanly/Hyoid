import 'package:flutter/material.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/assistant/data/models/assistant_consultation.dart';
import 'package:hyoid_app/features/assistant/data/services/assistant_api_service.dart';
import 'consultation_update_screen.dart';

class AssistantRequestsScreen extends StatefulWidget {
  const AssistantRequestsScreen({super.key});

  @override
  State<AssistantRequestsScreen> createState() => _AssistantRequestsScreenState();
}

class _AssistantRequestsScreenState extends State<AssistantRequestsScreen> {
  final AssistantApiService _apiService = AssistantApiService();
  late Future<List<AssistantConsultation>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _apiService.getRequests();
  }

  void _refresh() {
    setState(() {
      _requestsFuture = _apiService.getRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        title: const Text(
          'Assigned Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppTheme.darkSurface,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<AssistantConsultation>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.orangeAccent));
          }

          if (snapshot.hasError) {
            return _buildErrorState('Failed to load requests');
          }

          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _RequestCard(
                request: request,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConsultationUpdateScreen(
                        consultationId: request.id,
                        patientName: request.patientName,
                        initialSymptoms: request.symptoms,
                      ),
                    ),
                  );
                  if (result == true) {
                    _refresh();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white54)),
          TextButton(
            onPressed: _refresh,
            child: const Text('Retry', style: TextStyle(color: AppTheme.orangeAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, color: Colors.white.withValues(alpha: 0.1), size: 64),
          const SizedBox(height: 16),
          const Text(
            'No pending assignments',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final AssistantConsultation request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.orangeAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: AppTheme.orangeAccent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.patientName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.symptoms,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}
