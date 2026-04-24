// lib/main.dart
// ─────────────────────────────────────────────────────────────
// App entry point.
//
// Providers registered:
//   AuthProvider     — manages login state, OTP, Google sign-in, requiresPayment
//   PaymentProvider  — manages Razorpay payment lifecycle (NEW)
//   AppointmentProvider — appointment state
//   NotificationProvider — push notification state
//
// Home is SplashScreen which calls AuthProvider.initialize()
// and then routes to AuthGuard (auth/payment/home).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/screens/splash_screen.dart';
import 'package:hyoid_app/globals.dart';
import 'package:hyoid_app/providers/auth_provider.dart';
import 'package:hyoid_app/providers/payment_provider.dart';
import 'package:hyoid_app/providers/appointment_provider.dart';
import 'package:hyoid_app/providers/notification_provider.dart';
import 'package:hyoid_app/providers/user_provider.dart';

import 'package:flutter/foundation.dart'; // For kIsWeb

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        appId: "YOUR_APP_ID",
        messagingSenderId: "YOUR_SENDER_ID",
        projectId: "hyoid-87977", // Extracted from your JSON
        storageBucket: "hyoid-87977.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  await initializeGlobalState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const HyoidApp(),
    ),
  );
}

class HyoidApp extends StatefulWidget {
  const HyoidApp({super.key});

  @override
  State<HyoidApp> createState() => _HyoidAppState();
}

class _HyoidAppState extends State<HyoidApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAuthListener();
    });
  }

  void _setupAuthListener() {
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    auth.addListener(() {
      if (auth.isAuthenticated && userProvider.currentUser == null && !userProvider.isLoading) {
        userProvider.loadProfile();
      } else if (auth.isGuest && userProvider.currentUser != null) {
        userProvider.clearUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyoid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
