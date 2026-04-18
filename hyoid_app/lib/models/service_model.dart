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
}

