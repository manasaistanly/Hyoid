class Patient {
  final String id;
  final String name;
  final int age;
  final List<String>? medicalHistory;
  final Map<String, dynamic>? vitals;
  final String? symptoms;
  final String? assistantNotes;
  final List<String>? images;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    this.medicalHistory,
    this.vitals,
    this.symptoms,
    this.assistantNotes,
    this.images,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['patientName'] ?? json['name'] ?? 'Patient',
      age: json['age'] ?? 0,
      medicalHistory: json['medicalHistory'] != null 
          ? List<String>.from(json['medicalHistory']) 
          : null,
      vitals: json['vitals'] != null 
          ? Map<String, dynamic>.from(json['vitals']) 
          : null,
      symptoms: json['symptoms'],
      assistantNotes: json['assistantNotes'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }
}
