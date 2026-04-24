class AppointmentModel {
  final String? id;
  final dynamic userId; // Can be String ID or nested Map
  final String name;
  final int age;
  final String contact;
  final String symptoms;
  final String status;
  final dynamic assignedTo;
  final String type;
  final String? notes;
  final String preferredTime;
  final String priority;
  final String? adminNotes;
  final String? staffNotes;
  final String? createdAt;

  AppointmentModel({
    this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.contact,
    required this.symptoms,
    required this.status,
    this.assignedTo,
    required this.type,
    this.notes,
    required this.preferredTime,
    required this.priority,
    this.adminNotes,
    this.staffNotes,
    this.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      contact: json['contact'] ?? '',
      symptoms: json['symptoms'] ?? '',
      status: json['status'] ?? 'pending',
      assignedTo: json['assignedTo'],
      type: json['type'] ?? 'doctor',
      notes: json['notes'],
      preferredTime: json['preferredTime'] ?? '',
      priority: json['priority'] ?? 'normal',
      adminNotes: json['adminNotes'],
      staffNotes: json['staffNotes'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'name': name,
      'age': age,
      'contact': contact,
      'symptoms': symptoms,
      'status': status,
      if (assignedTo != null) 'assignedTo': assignedTo,
      'type': type,
      if (notes != null) 'notes': notes,
      'preferredTime': preferredTime,
      'priority': priority,
      if (adminNotes != null) 'adminNotes': adminNotes,
      if (staffNotes != null) 'staffNotes': staffNotes,
    };
  }

  AppointmentModel copyWith({
    String? id,
    dynamic userId,
    String? name,
    int? age,
    String? contact,
    String? symptoms,
    String? status,
    dynamic assignedTo,
    String? type,
    String? notes,
    String? preferredTime,
    String? priority,
    String? adminNotes,
    String? staffNotes,
    String? createdAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      contact: contact ?? this.contact,
      symptoms: symptoms ?? this.symptoms,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      preferredTime: preferredTime ?? this.preferredTime,
      priority: priority ?? this.priority,
      adminNotes: adminNotes ?? this.adminNotes,
      staffNotes: staffNotes ?? this.staffNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
