import 'package:flutter/material.dart';

class LabTest {
  final String id;
  final String title;
  final String description;
  final String specimen;
  final int price;
  final IconData icon;
  final Color color;

  LabTest({
    required this.id,
    required this.title,
    required this.description,
    required this.specimen,
    required this.price,
    required this.icon,
    required this.color,
  });
}

class LabReportItem {
  final String name;
  final String result;
  final String normalRange;

  LabReportItem({
    required this.name,
    required this.result,
    required this.normalRange,
  });
}

class LabReport {
  final String id;
  final String title;
  final String provider;
  final DateTime requestedAt;
  final String status;
  final List<LabReportItem> results;
  final int amount;
  final bool sharedWithDoctor;

  LabReport({
    required this.id,
    required this.title,
    required this.provider,
    required this.requestedAt,
    required this.status,
    required this.results,
    required this.amount,
    this.sharedWithDoctor = false,
  });

  LabReport copyWith({
    String? status,
    bool? sharedWithDoctor,
    List<LabReportItem>? results,
  }) {
    return LabReport(
      id: id,
      title: title,
      provider: provider,
      requestedAt: requestedAt,
      status: status ?? this.status,
      results: results ?? this.results,
      amount: amount,
      sharedWithDoctor: sharedWithDoctor ?? this.sharedWithDoctor,
    );
  }
}
