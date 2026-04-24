// lib/widgets/login_prompt_sheet.dart
// ─────────────────────────────────────────────────────────────
// Login prompt bottom sheet — shown when a guest taps a
// protected action. Matches the existing dark theme exactly.
//
// Usage:
//   await showLoginPromptSheet(context, actionDescription: 'book an appointment');
//
// Buttons:
//   "Sign In"         → pushes LoginScreen, sheet closes
//   "Create Account"  → pushes RegisterScreen, sheet closes
//   "Continue browsing" → dismisses sheet, stays as guest
//
// After successful login, PendingActionService.executePending()
// is called by AuthProvider, which fires the saved action.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

/// Shows the login prompt as a modal bottom sheet.
/// Returns when the sheet is dismissed (any action).
Future<void> showLoginPromptSheet(
  BuildContext context, {
  String actionDescription = 'continue',
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => LoginPromptSheet(actionDescription: actionDescription),
  );
}

class LoginPromptSheet extends StatelessWidget {
  final String actionDescription;

  const LoginPromptSheet({super.key, required this.actionDescription});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // App logo / icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.pureBlack,
              border: Border.all(
                color: AppTheme.orangeAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Sign in to continue',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle with action description
          Text(
            'You need an account to $actionDescription.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Sign In button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Create Account button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.borderCol),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Continue browsing link
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Continue browsing',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
