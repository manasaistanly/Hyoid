import 'package:flutter/material.dart';

class NotificationModel {
  final String? id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final String? appointmentId;
  final String? createdAt;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    this.appointmentId,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      read: json['read'] ?? false,
      appointmentId: json['appointmentId'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'body': body,
      'type': type,
      'read': read,
      if (appointmentId != null) 'appointmentId': appointmentId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    bool? read,
    String? appointmentId,
    String? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      read: read ?? this.read,
      appointmentId: appointmentId ?? this.appointmentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Getters for compatibility with UI code
  bool get isRead => read;
  String get message => body;

  // Get color based on notification type
  Color getColor() {
    return switch (type) {
      'urgent' => const Color(0xFFFF6B6B),
      'appointment' => const Color(0xFF4ECDC4),
      'success' => const Color(0xFF51CF66),
      'warning' => const Color(0xFFFFA94D),
      _ => const Color(0xFF95E1D3),
    };
  }

  // Get icon based on notification type
  IconData getIcon() {
    return switch (type) {
      'urgent' => Icons.priority_high,
      'appointment' => Icons.calendar_today,
      'success' => Icons.check_circle,
      'warning' => Icons.warning,
      _ => Icons.notifications,
    };
  }

  // Get time ago string
  String getTimeAgo() {
    if (createdAt == null) return 'Just now';
    try {
      final dateTime = DateTime.parse(createdAt!);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return dateTime.toString().split(' ')[0];
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
