// lib/core/guards/auth_guard.dart
// ─────────────────────────────────────────────────────────────
// Route guard widget — decides which screen to show on app start
// and after any auth state change.
//
// Logic:
//   1. Not authenticated → LoginScreen
//   2. Authenticated + requiresPayment == true → PaymentScreen
//   3. Authenticated + paid + role==doctor → DoctorShell
//   4. Authenticated + paid + role==patient → MainNavigationScreen
//
// Used by: SplashScreen after AuthProvider.initialize() completes,
//          and can be used as the root home widget.
//
// Also handles 402 responses: any Dio 402 should set requiresPayment
// in AuthProvider, which this guard will detect.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../screens/payment_screen.dart';
import '../../screens/main_navigation_screen.dart';
import '../../features/doctor/shell/doctor_shell.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.loading:
        // Show a minimal loading indicator while checking auth state
        return const Scaffold(
          backgroundColor: Color(0xFF0A0A0A),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6600)),
          ),
        );

      case AuthStatus.authenticated:
        if (auth.requiresPayment) {
          return const PaymentScreen();
        }
        final role = auth.currentUser?.role ?? 'patient';
        return role == 'doctor'
            ? const DoctorShell()
            : const MainNavigationScreen();

      case AuthStatus.guest:
      case AuthStatus.initial:
      case AuthStatus.error:
      default:
        // Guest mode — users can browse without logging in
        return const MainNavigationScreen();
    }
  }
}
