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

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: json['_id']?.toString() ?? '',
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      specimen: json['specimen'] ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      icon: _getIcon(json['icon']),
      color: const Color(0xFFA78BFA), // Default violet for labs
    );
  }

  static IconData _getIcon(String? name) {
    switch (name) {
      case 'biotech_rounded': return Icons.biotech_rounded;
      case 'opacity_rounded': return Icons.opacity_rounded;
      case 'monitor_heart_rounded': return Icons.monitor_heart_rounded;
      default: return Icons.science_rounded;
    }
  }
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
