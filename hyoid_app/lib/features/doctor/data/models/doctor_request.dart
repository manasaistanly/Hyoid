enum RequestPriority { normal, emergency }

enum RequestStatus { pending, accepted, completed, rejected }

class DoctorRequest {
  final String id;
  final String patientId;
  final String patientName;
  final int age;
  final String symptoms;
  final RequestPriority priority;
  final RequestStatus status;
  final DateTime time;
  final String? assistantNotes;
  final List<String>? images;

  DoctorRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.age,
    required this.symptoms,
    required this.priority,
    required this.status,
    required this.time,
    this.assistantNotes,
    this.images,
  });

  factory DoctorRequest.fromJson(Map<String, dynamic> json) {
    return DoctorRequest(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      patientName: json['patientName'] ?? '',
      age: json['age'] ?? 0,
      symptoms: json['symptoms'] ?? '',
      priority: (json['priority'] == 'emergency')
          ? RequestPriority.emergency
          : RequestPriority.normal,
      status: _parseStatus(json['status']),
      time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      assistantNotes: json['assistantNotes'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  static RequestStatus _parseStatus(String? status) {
    switch (status) {
      case 'accepted':
        return RequestStatus.accepted;
      case 'completed':
        return RequestStatus.completed;
      case 'rejected':
        return RequestStatus.rejected;
      default:
        return RequestStatus.pending;
    }
  }
}
