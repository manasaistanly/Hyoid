// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/auth/post_login_redirect.dart';
import '../../widgets/login_prompt_sheet.dart';

/// Runs [action] immediately if authenticated, otherwise saves it and
/// shows a login prompt bottom sheet.
Future<void> guardedAction(
  BuildContext context,
  VoidCallback action, {
  String actionDescription = 'continue',
}) async {
  final auth = context.read<AuthProvider>();

  if (!auth.isGuest) {
    // Already logged in — run immediately
    action();
    return;
  }

  // Save the action so it fires after login
  pendingActionService.setPending(action);

  // Show login prompt
  if (context.mounted) {
    await showLoginPromptSheet(context, actionDescription: actionDescription);
  }
}

/// Widget wrapper that intercepts any child tap and guards it.
/// Provide [onAuthenticated] as the action to run after login.
class GuestGuard extends StatelessWidget {
  final Widget child;
  final VoidCallback onAuthenticated;
  final String actionDescription;

  const GuestGuard({
    super.key,
    required this.child,
    required this.onAuthenticated,
    this.actionDescription = 'continue',
  });

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AuthProvider>().isGuest;

    if (!isGuest) {
      return child; // Authenticated — render as-is
    }

    // Wrap child in a GestureDetector that intercepts taps
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => guardedAction(
        context,
        onAuthenticated,
        actionDescription: actionDescription,
      ),
      child: AbsorbPointer(child: child),
    );
  }
}
