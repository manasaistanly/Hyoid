class Prescription {
  final String id;
  final String consultationId;
  final String doctorId;
  final String patientId;
  final DateTime issuedAt;
  final String diagnosis;
  final List<PrescriptionItem> medicines;
  final String? notes;
  final String doctorSignature;
  final bool isDigital;

  Prescription({
    required this.id,
    required this.consultationId,
    required this.doctorId,
    required this.patientId,
    required this.issuedAt,
    required this.diagnosis,
    required this.medicines,
    this.notes,
    required this.doctorSignature,
    required this.isDigital,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['_id'] ?? json['id'],
      consultationId: json['consultationId'],
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      issuedAt: DateTime.parse(json['issuedAt']),
      diagnosis: json['diagnosis'],
      medicines: (json['medicines'] as List<dynamic>?)
          ?.map((item) => PrescriptionItem.fromJson(item))
          .toList() ?? [],
      notes: json['notes'],
      doctorSignature: json['doctorSignature'],
      isDigital: json['isDigital'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consultationId': consultationId,
      'doctorId': doctorId,
      'patientId': patientId,
      'issuedAt': issuedAt.toIso8601String(),
      'diagnosis': diagnosis,
      'medicines': medicines.map((item) => item.toJson()).toList(),
      'notes': notes,
      'doctorSignature': doctorSignature,
      'isDigital': isDigital,
    };
  }
}

class PrescriptionItem {
  final String medicineName;
  final String dosage;
  final String frequency;
  final int duration; // in days
  final String instructions;
  final String? genericAlternative;

  PrescriptionItem({
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
    this.genericAlternative,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      medicineName: json['medicineName'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
      instructions: json['instructions'],
      genericAlternative: json['genericAlternative'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
      'genericAlternative': genericAlternative,
    };
  }
}