// lib/core/auth/post_login_redirect.dart
// ─────────────────────────────────────────────────────────────
// PendingActionService — stores a callback that was blocked by
// guest mode and re-executes it automatically after login.
//
// Flow:
//   1. Guest taps protected action
//   2. guardedAction() calls pendingActionService.setPending(theAction)
//   3. LoginPromptSheet / LoginScreen is shown
//   4. After AuthProvider emits `authenticated`:
//      → AuthProvider calls pendingActionService.executePending()
//      → Stored callback fires automatically
//
// This is a simple singleton — no DI framework needed.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class PendingActionService {
  PendingActionService._();
  static final PendingActionService instance = PendingActionService._();

  VoidCallback? _pendingAction;

  /// Saves a callback to be executed after login succeeds.
  void setPending(VoidCallback action) => _pendingAction = action;

  /// Executes the stored callback once, then clears it.
  void executePending() {
    _pendingAction?.call();
    _pendingAction = null;
  }

  /// Clears any pending action without executing it.
  void clear() => _pendingAction = null;

  bool get hasPending => _pendingAction != null;
}

/// Global singleton instance for convenience.
final pendingActionService = PendingActionService.instance;
