import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import '../../../models/appointment_model.dart';
import 'appointment_history_screen.dart';

class TrackAppointmentScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const TrackAppointmentScreen({super.key, required this.appointment});

  @override
  State<TrackAppointmentScreen> createState() => _TrackAppointmentScreenState();
}

class _TrackAppointmentScreenState extends State<TrackAppointmentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> statuses = [
    'pending',
    'contacted',
    'assigned',
    'confirmed',
    'completed',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int get currentStep {
    final index = statuses.indexOf(widget.appointment.status.toLowerCase());
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        title: const Text('Track Appointment'),
        backgroundColor: AppTheme.darkSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppointmentHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Request ID: #${(widget.appointment.id ?? '').isNotEmpty ? widget.appointment.id!.substring(0, 6) : "NEW"}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.appointment.priority == 'urgent'
                              ? AppTheme.dangerRed.withValues(alpha: 0.2)
                              : AppTheme.successGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.appointment.priority.toUpperCase(),
                          style: TextStyle(
                            color: widget.appointment.priority == 'urgent'
                                ? AppTheme.dangerRed
                                : AppTheme.successGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.appointment.type[0].toUpperCase()}${widget.appointment.type.substring(1)} Triage Request',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.appointment.symptoms,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Animated Stepper
            _buildStepper(),

            const SizedBox(height: 60),

            // Active action banner based on status
            _buildActionBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Column(
      children: List.generate(statuses.length, (index) {
        final statusLabel = statuses[index];
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        final isLast = index == statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // Node
                if (isActive)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _animation.value,
                        child: _buildNode(isActive, isCompleted),
                      );
                    },
                  )
                else
                  _buildNode(isActive, isCompleted),

                // Line
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted
                        ? AppTheme.successGreen
                        : AppTheme.borderCol,
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusLabel[0].toUpperCase() + statusLabel.substring(1),
                      style: TextStyle(
                        color: isActive || isCompleted
                            ? Colors.white
                            : Colors.white54,
                        fontSize: 16,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDescriptionForStatus(statusLabel),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNode(bool isActive, bool isCompleted) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.successGreen
            : isActive
            ? AppTheme.orangeAccent
            : AppTheme.darkSurface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted
              ? AppTheme.successGreen
              : isActive
              ? AppTheme.orangeAccent
              : AppTheme.borderCol,
          width: 2,
        ),
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : isActive
          ? const Center(
              child: CircleAvatar(radius: 4, backgroundColor: Colors.white),
            )
          : null,
    );
  }

  String _getDescriptionForStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Your request has been received.';
      case 'contacted':
        return 'An admin reviewed your request and is arranging care.';
      case 'assigned':
        return 'A professional has been assigned to your case.';
      case 'confirmed':
        return 'Your appointment schedule is confirmed.';
      case 'completed':
        return 'Appointment completed successfully.';
      default:
        return '';
    }
  }

  Widget _buildActionBanner() {
    if (widget.appointment.status == 'assigned' ||
        widget.appointment.status == 'confirmed') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.orangeAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.orangeAccent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.orangeAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.appointment.assignedTo.isNotEmpty
                        ? widget.appointment.assignedTo
                        : 'Assigned Provider',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'They will arrive as scheduled.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
