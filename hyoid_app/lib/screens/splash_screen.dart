import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/providers/auth_provider.dart';
import 'package:hyoid_app/core/guards/auth_guard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _logoScale;
  late Animation<double> _logoGlow;

  final String _brandText = "HYOID";
  final List<Animation<double>> _letterFades = [];
  final List<Animation<Offset>> _letterSlides = [];

  @override
  void initState() {
    super.initState();

    // Overall Sequence: 2.5 Seconds
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 1. Logo Pops in with Elastic spring effect (0% -> 40% of standard duration)
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    // 2. Logo slowly begins to emit Premium Glow (40% -> 80% duration bounds)
    _logoGlow = Tween<double>(begin: 0.0, end: 40.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );

    // 3. Staggered Word Reveal "H Y O I D"
    double startInterval = 0.35; // Begins slightly before logo glow
    for (int i = 0; i < _brandText.length; i++) {
      double endInterval = (startInterval + 0.2).clamp(0.0, 1.0);

      _letterFades.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: Interval(startInterval, endInterval, curve: Curves.easeIn),
          ),
        ),
      );
      _letterSlides.add(
        Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: Interval(
              startInterval,
              endInterval,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );

      startInterval += 0.1; // Stagger each letter's entry smoothly
    }

    _mainController.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    // Call /api/auth/me — if token exists and is valid, user is set.
    // AuthProvider.initialize() returns true if authenticated.
    await context.read<AuthProvider>().initialize();

    if (!mounted) return;
    // AuthGuard reads the auth state and decides which screen to show.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthGuard()),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: Center(
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Animated Logo
                Transform.scale(
                  scale: _logoScale.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.orangeAccent.withValues(alpha: 0.3),
                          blurRadius: _logoGlow.value,
                          spreadRadius: _logoGlow.value / 4,
                        ),
                      ],
                    ),
                    child: _buildLogoWidget(),
                  ),
                ),

                const SizedBox(height: 24),

                // Staggered Animated Word
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_brandText.length, (index) {
                    return SlideTransition(
                      position: _letterSlides[index],
                      child: FadeTransition(
                        opacity: _letterFades[index],
                        child: Text(
                          _brandText[index],
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 8, // Intense tracking
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoWidget() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white, // Matches the reference image background
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.cover, // Zoom into the circular part of the reference
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.orangeAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width * 0.2, size.height / 2);
    path.lineTo(size.width * 0.3, 0); // spike up
    path.lineTo(size.width * 0.4, size.height); // spike down
    path.lineTo(size.width * 0.5, size.height / 2);
    path.lineTo(size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
