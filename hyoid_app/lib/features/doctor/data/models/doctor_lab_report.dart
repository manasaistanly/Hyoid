enum ReportStatus { pending, completed }

class DoctorLabReport {
  final String id;
  final String patientId;
  final String patientName;
  final String testName;
  final String? fileUrl;
  final ReportStatus status;
  final DateTime date;

  DoctorLabReport({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.testName,
    this.fileUrl,
    required this.status,
    required this.date,
  });

  factory DoctorLabReport.fromJson(Map<String, dynamic> json) {
    return DoctorLabReport(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      patientName: json['patientName'] ?? '',
      testName: json['testName'] ?? '',
      fileUrl: json['file'],
      status: (json['status'] == 'completed') ? ReportStatus.completed : ReportStatus.pending,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }
}
