class Consultation {
  final String id;
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String status; // 'waiting', 'active', 'completed'
  final String type; // 'chat', 'video'
  final List<ConsultationMessage> messages;
  final int queuePosition;
  final Duration? estimatedWaitTime;

  Consultation({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.startedAt,
    this.endedAt,
    required this.status,
    required this.type,
    required this.messages,
    required this.queuePosition,
    this.estimatedWaitTime,
  });

  Consultation copyWith({
    String? id,
    String? appointmentId,
    String? doctorId,
    String? patientId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? status,
    String? type,
    List<ConsultationMessage>? messages,
    int? queuePosition,
    Duration? estimatedWaitTime,
  }) {
    return Consultation(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      type: type ?? this.type,
      messages: messages ?? this.messages,
      queuePosition: queuePosition ?? this.queuePosition,
      estimatedWaitTime: estimatedWaitTime ?? this.estimatedWaitTime,
    );
  }

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['_id'] ?? json['id'],
      appointmentId: json['appointmentId'],
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      status: json['status'],
      type: json['type'],
      messages: (json['messages'] as List<dynamic>?)
          ?.map((msg) => ConsultationMessage.fromJson(msg))
          .toList() ?? [],
      queuePosition: json['queuePosition'] ?? 0,
      estimatedWaitTime: json['estimatedWaitTime'] != null
          ? Duration(seconds: json['estimatedWaitTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'patientId': patientId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'status': status,
      'type': type,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'queuePosition': queuePosition,
      'estimatedWaitTime': estimatedWaitTime?.inSeconds,
    };
  }
}

class ConsultationMessage {
  final String id;
  final String senderId;
  final String senderType; // 'doctor', 'patient'
  final String type; // 'text', 'image', 'voice', 'file'
  final String content;
  final DateTime timestamp;
  final bool isRead;

  ConsultationMessage({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.type,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory ConsultationMessage.fromJson(Map<String, dynamic> json) {
    return ConsultationMessage(
      id: json['_id'] ?? json['id'],
      senderId: json['senderId'],
      senderType: json['senderType'],
      type: json['type'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderType': senderType,
      'type': type,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}