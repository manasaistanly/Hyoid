class Prescription {
  final String id;
  final String patientId;
  final String doctorId;
  final List<String> medicines;
  final String notes;
  final DateTime date;

  Prescription({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.medicines,
    required this.notes,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'medicines': medicines,
      'notes': notes,
    };
  }
}
