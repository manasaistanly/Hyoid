class Medicine {
  final String name;
  final String dosage;
  final String duration;

  Medicine({
    required this.name,
    required this.dosage,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'duration': duration,
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      duration: json['duration'] ?? '',
    );
  }
}

class Prescription {
  final List<Medicine> medicines;
  final String notes;

  Prescription({
    required this.medicines,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicines': medicines.map((m) => m.toJson()).toList(),
      'notes': notes,
    };
  }

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      medicines: (json['medicines'] as List?)
              ?.map((m) => Medicine.fromJson(m))
              .toList() ??
          [],
      notes: json['notes'] ?? '',
    );
  }
}
