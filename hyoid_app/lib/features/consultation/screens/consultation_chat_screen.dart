import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import '../models/appointment_model.dart';
import '../models/consultation_model.dart';
import '../models/doctor_model.dart';
import '../services/consultation_service.dart';
import 'prescription_screen.dart';

class ConsultationChatScreen extends StatefulWidget {
  final Appointment appointment;
  final Doctor doctor;

  const ConsultationChatScreen({
    super.key,
    required this.appointment,
    required this.doctor,
  });

  @override
  State<ConsultationChatScreen> createState() => _ConsultationChatScreenState();
}

class _ConsultationChatScreenState extends State<ConsultationChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Consultation? _consultation;
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _initializeConsultation();
    _startStatusUpdates();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeConsultation() async {
    try {
      final consultation = await ConsultationService.startConsultation(
        appointmentId: widget.appointment.id,
        doctorId: widget.doctor.id,
        patientId: widget.appointment.patientId,
        type: widget.appointment.type,
      );

      setState(() {
        _consultation = consultation;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start consultation: $e')),
      );
    }
  }

  void _startStatusUpdates() {
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // TODO: Implement real-time status updates via WebSocket
      // For now, simulate status updates
      if (_consultation != null && mounted) {
        setState(() {
          // Simulate doctor joining after some time
          if (_consultation!.status == 'waiting' && timer.tick > 3) {
            _consultation = _consultation!.copyWith(status: 'active');
          }
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String content, {String type = 'text'}) async {
    if (content.trim().isEmpty || _consultation == null) return;

    setState(() => _isSending = true);

    final message = ConsultationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.appointment.patientId,
      senderType: 'patient',
      type: type,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _consultation = _consultation!.copyWith(
        messages: [..._consultation!.messages, message],
      );
    });

    _messageController.clear();
    _scrollToBottom();

    // TODO: Send message via WebSocket/API
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    setState(() => _isSending = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // TODO: Upload image and get URL
      await _sendMessage(image.path, type: 'image');
    }
  }

  Future<void> _recordVoiceNote() async {
    // TODO: Implement voice recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice notes coming soon!')),
    );
  }

  void _endConsultation() async {
    if (_consultation == null) return;

    try {
      await ConsultationService.endConsultation(_consultation!.id);

      if (!mounted) return;

      // Navigate to prescription screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PrescriptionScreen(
            consultation: _consultation!,
            doctor: widget.doctor,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to end consultation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.pureBlack,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.darkSurface,
          title: const Text('Starting Consultation...', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.orangeAccent)),
      );
    }

    if (_consultation == null) {
      return Scaffold(
        backgroundColor: AppTheme.pureBlack,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.darkSurface,
          title: const Text('Consultation', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text('Failed to start consultation', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.darkSurface,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
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
                      child: const Icon(Icons.person, color: Colors.white, size: 16),
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
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _getStatusText(),
                    style: TextStyle(color: _getStatusColor(), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: _endConsultation,
            tooltip: 'End Consultation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Banner
          if (_consultation!.status == 'waiting')
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You are ${_consultation!.queuePosition} in line. Estimated wait: ${_formatDuration(_consultation!.estimatedWaitTime)}',
                      style: const TextStyle(color: Colors.orange, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _consultation!.messages.length,
              itemBuilder: (context, index) {
                final message = _consultation!.messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              border: const Border(top: BorderSide(color: Color(0xFF2E2E2E), width: 1)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.white54),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.white54),
                  onPressed: _recordVoiceNote,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppTheme.orangeAccent),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isSending ? null : () => _sendMessage(_messageController.text),
                  backgroundColor: AppTheme.orangeAccent,
                  mini: true,
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (_consultation!.status) {
      case 'waiting':
        return 'Waiting in queue';
      case 'active':
        return 'Consultation active';
      case 'completed':
        return 'Consultation ended';
      default:
        return 'Connecting...';
    }
  }

  Color _getStatusColor() {
    switch (_consultation!.status) {
      case 'waiting':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.white54;
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'Unknown';
    final minutes = duration.inMinutes;
    return '$minutes min';
  }
}

class MessageBubble extends StatelessWidget {
  final ConsultationMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isPatient = message.senderType == 'patient';
    final alignment = isPatient ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPatient ? AppTheme.orangeAccent : AppTheme.darkSurface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isPatient ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight: isPatient ? const Radius.circular(4) : const Radius.circular(16),
              ),
              border: Border.all(
                color: const Color(0xFF2E2E2E),
                width: 1,
              ),
            ),
            child: _buildMessageContent(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatTime(message.timestamp),
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(message.content),
                width: 200,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(message.content, style: const TextStyle(color: Colors.white)),
            ],
          ],
        );
      case 'voice':
        return Row(
          children: [
            const Icon(Icons.play_arrow, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('0:15', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        );
      default:
        return Text(
          message.content,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}