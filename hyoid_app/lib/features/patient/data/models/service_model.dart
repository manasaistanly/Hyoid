import 'package:flutter/material.dart';

class ServiceBooking {
  final String title;
  final String subtitle;
  final String providerName;
  final String specialization;
  final IconData icon;
  final Color color;
  final Color glowColor;
  final int priceFrom;

  const ServiceBooking({
    required this.title,
    required this.subtitle,
    required this.providerName,
    required this.specialization,
    required this.icon,
    required this.color,
    required this.glowColor,
    required this.priceFrom,
  });

  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      title: json['name'] ?? '',
      subtitle: json['description'] ?? '',
      providerName: 'Verified Provider', // Default for master data
      specialization: json['type'] ?? '',
      icon: _getIcon(json['icon']),
      color: _getColor(json['color']),
      glowColor: _getColor(json['color']).withValues(alpha: 0.15),
      priceFrom: (json['price'] as num?)?.toInt() ?? 0,
    );
  }

  static IconData _getIcon(String? name) {
    switch (name) {
      case 'medical_services_rounded': return Icons.medical_services_rounded;
      case 'videocam_rounded': return Icons.videocam_rounded;
      case 'home_rounded': return Icons.home_rounded;
      case 'science_rounded': return Icons.science_rounded;
      case 'local_pharmacy_rounded': return Icons.local_pharmacy_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  static Color _getColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }
}
