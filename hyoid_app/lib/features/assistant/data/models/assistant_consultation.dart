class AssistantConsultation {
  final String id;
  final String patientId;
  final String patientName;
  final String symptoms;
  final String? assistantNotes;
  final Vitals? vitals;
  final String status;
  final DateTime createdAt;

  AssistantConsultation({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.symptoms,
    this.assistantNotes,
    this.vitals,
    required this.status,
    required this.createdAt,
  });

  factory AssistantConsultation.fromJson(Map<String, dynamic> json) {
    return AssistantConsultation(
      id: json['_id'] ?? '',
      patientId: json['patientId'] is Map 
          ? json['patientId']['_id'] ?? '' 
          : json['patientId'] ?? '',
      patientName: json['patientId'] is Map 
          ? json['patientId']['name'] ?? 'Unknown' 
          : 'Patient',
      symptoms: json['symptoms'] ?? '',
      assistantNotes: json['assistantNotes'],
      vitals: json['vitals'] != null ? Vitals.fromJson(json['vitals']) : null,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class Vitals {
  final String? bp;
  final String? sugar;
  final String? temperature;

  Vitals({this.bp, this.sugar, this.temperature});

  factory Vitals.fromJson(Map<String, dynamic> json) {
    return Vitals(
      bp: json['bp'],
      sugar: json['sugar'],
      temperature: json['temperature'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bp': bp,
      'sugar': sugar,
      'temperature': temperature,
    };
  }
}
