class NurseBooking {
  final String id;
  final String userId;
  final String nurseId;
  final String serviceType;
  final DateTime date;
  final String time;
  final int duration;
  final String? notes;
  final String status;
  final Map<String, dynamic> location;
  final Map<String, dynamic> payment;
  final Map<String, dynamic>? recurring;

  NurseBooking({
    required this.id,
    required this.userId,
    required this.nurseId,
    required this.serviceType,
    required this.date,
    required this.time,
    required this.duration,
    this.notes,
    required this.status,
    required this.location,
    required this.payment,
    this.recurring,
  });

  factory NurseBooking.fromJson(Map<String, dynamic> json) {
    return NurseBooking(
      id: json['_id'],
      userId: json['userId'],
      nurseId: json['nurseId'],
      serviceType: json['serviceType'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      duration: json['duration'],
      notes: json['notes'],
      status: json['status'],
      location: json['location'],
      payment: json['payment'],
      recurring: json['recurring'],
    );
  }
}