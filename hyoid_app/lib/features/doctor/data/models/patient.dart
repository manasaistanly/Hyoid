class Patient {
  final String id;
  final String name;
  final int age;
  final List<String>? medicalHistory;
  final Map<String, String>? vitals;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    this.medicalHistory,
    this.vitals,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      medicalHistory: json['medicalHistory'] != null ? List<String>.from(json['medicalHistory']) : null,
      vitals: json['vitals'] != null ? Map<String, String>.from(json['vitals']) : null,
    );
  }
}
