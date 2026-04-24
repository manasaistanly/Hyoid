// lib/screens/payment_screen.dart
// ─────────────────────────────────────────────────────────────
// Payment screen — shown after login when requiresPayment == true.
//
// Flow:
//   1. Displays plan details (₹999 one-time)
//   2. "Pay Now" → PaymentProvider.createAndLaunchPayment()
//   3. Razorpay SDK opens natively
//   4. On success → PaymentProvider verifies with backend → AuthProvider.markAsPaid()
//   5. Navigate to HomeScreen
//   6. On failure → show error, allow retry — NO navigation to home
//
// Back navigation is blocked — user MUST pay or be logged out.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/providers/auth_provider.dart';
import 'package:hyoid_app/providers/payment_provider.dart';
import 'package:hyoid_app/screens/main_navigation_screen.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentProvider _paymentProvider;

  @override
  void initState() {
    super.initState();
    _paymentProvider = context.read<PaymentProvider>();
    _paymentProvider.initRazorpay();

    // Wire payment success → mark user as paid in AuthProvider
    _paymentProvider.onPaymentVerified = () {
      if (mounted) {
        context.read<AuthProvider>().markAsPaid();
        // Navigate to home after brief delay for state propagation
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _navigateToHome();
        });
      }
    };
  }

  @override
  void dispose() {
    _paymentProvider.disposeRazorpay();
    super.dispose();
  }

  void _navigateToHome() {
    final role = context.read<AuthProvider>().currentUser?.role ?? 'patient';
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => role == 'doctor'
            ? const DoctorShell()
            : const MainNavigationScreen(),
      ),
      (route) => false,
    );
  }

  void _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final payment = context.watch<PaymentProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    // If payment just succeeded and we haven't navigated yet
    if (payment.status == PaymentStatus.success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _navigateToHome();
      });
    }

    return PopScope(
      canPop: false, // Block hardware back button
      child: Scaffold(
        backgroundColor: AppTheme.pureBlack,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HYOID',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    TextButton(
                      onPressed: _logout,
                      child: const Text(
                        'Log out',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                const Text(
                  'Unlock Full Access',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hey ${user?.name ?? 'there'}, complete your plan to start using Hyoid.',
                  style: const TextStyle(color: Colors.white60, fontSize: 15),
                ),

                const SizedBox(height: 32),

                // ── Plan Card ─────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.orangeAccent.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.orangeAccent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_hospital_rounded,
                              color: AppTheme.orangeAccent, size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'Hyoid Health Plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.orangeAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ONE-TIME',
                              style: TextStyle(
                                color: AppTheme.orangeAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '₹999',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'one-time payment',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFF333333)),
                      const SizedBox(height: 16),
                      _buildFeature(Icons.science_rounded, 'Lab tests & diagnostics'),
                      _buildFeature(Icons.medical_services_rounded, 'Doctor consultations'),
                      _buildFeature(Icons.healing_rounded, 'Nurse home visits'),
                      _buildFeature(Icons.monitor_heart_rounded, 'Vital tracking'),
                      _buildFeature(Icons.notifications_rounded, 'Health alerts & notifications'),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Error message ─────────────────────────────────────
                if (payment.status == PaymentStatus.failed &&
                    payment.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            payment.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Pay Button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: payment.isLoading
                        ? null
                        : () => payment.createAndLaunchPayment(
                              userName: user?.name,
                              userEmail: user?.email,
                              userPhone: user?.phone,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: payment.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            payment.status == PaymentStatus.failed
                                ? 'Retry Payment'
                                : 'Pay ₹999 — Get Full Access',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    '🔒  Secured by Razorpay',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.orangeAccent, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}
