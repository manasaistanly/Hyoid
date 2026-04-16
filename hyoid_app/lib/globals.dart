import 'package:flutter/foundation.dart';

// Global state mock for active bookings
final ValueNotifier<bool> globalHasActiveBooking = ValueNotifier<bool>(false);

// Global notification count badge
final ValueNotifier<int> globalNotifCount = ValueNotifier<int>(3);
