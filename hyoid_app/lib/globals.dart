import 'package:flutter/foundation.dart';
import 'package:hyoid_app/models/service_model.dart';
import 'package:hyoid_app/models/lab_test_model.dart';

// Global state mock for active bookings
final ValueNotifier<bool> globalHasActiveBooking = ValueNotifier<bool>(false);
ServiceBooking? globalActiveBooking;

// Global notification count badge
final ValueNotifier<int> globalNotifCount = ValueNotifier<int>(3);

// Lab cart and report state
final ValueNotifier<List<LabTest>> globalLabCart = ValueNotifier<List<LabTest>>([]);
final ValueNotifier<List<LabReport>> globalLabReports = ValueNotifier<List<LabReport>>([]);
