import 'package:flutter/material.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/auth/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HyoidApp());
}

class HyoidApp extends StatelessWidget {
  const HyoidApp({super.key});

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
