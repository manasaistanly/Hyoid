class Appointment {
  final String id;
  final String doctorId;
  final String patientId;
  final DateTime scheduledAt;
  final String status; // 'scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled'
  final String type; // 'chat', 'video'
  final int fee;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.scheduledAt,
    required this.status,
    required this.type,
    required this.fee,
    this.notes,
    required this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] ?? json['id'],
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      scheduledAt: DateTime.parse(json['scheduledAt']),
      status: json['status'],
      type: json['type'],
      fee: json['fee'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'scheduledAt': scheduledAt.toIso8601String(),
      'status': status,
      'type': type,
      'fee': fee,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}