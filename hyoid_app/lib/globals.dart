import 'package:flutter/foundation.dart';
import 'package:hyoid_app/models/service_model.dart';
import 'package:hyoid_app/models/lab_test_model.dart';
import 'package:hyoid_app/services/notification_service.dart';

// Global state mock for active bookings
final ValueNotifier<bool> globalHasActiveBooking = ValueNotifier<bool>(false);
ServiceBooking? globalActiveBooking;

// Global notification count badge - initialized from notification service
final ValueNotifier<int> globalNotifCount = ValueNotifier<int>(0);

// Initialize global state
Future<void> initializeGlobalState() async {
  // Initialize notification service and update badge count
  await NotificationService.initialize();
  globalNotifCount.value = NotificationService.unreadCount;
}

// Lab cart and report state
final ValueNotifier<List<LabTest>> globalLabCart = ValueNotifier<List<LabTest>>([]);
final ValueNotifier<List<LabReport>> globalLabReports = ValueNotifier<List<LabReport>>([]);
