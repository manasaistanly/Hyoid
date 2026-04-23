import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/patient/presentation/screens/main_navigation_screen.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart';
import 'package:hyoid_app/features/auth/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _logoScale;
  late Animation<double> _logoGlow;
  
  final String _brandText = "HYOID";
  final List<Animation<double>> _letterFades = [];
  final List<Animation<Offset>> _letterSlides = [];

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4, curve: Curves.elasticOut))
    );
    
    _logoGlow = Tween<double>(begin: 0.0, end: 40.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.8, curve: Curves.easeInOut))
    );
    
    double startInterval = 0.35;
    for (int i = 0; i < _brandText.length; i++) {
       double endInterval = (startInterval + 0.2).clamp(0.0, 1.0);
       
       _letterFades.add(Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _mainController, curve: Interval(startInterval, endInterval, curve: Curves.easeIn))
       ));
       _letterSlides.add(Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero).animate(
          CurvedAnimation(parent: _mainController, curve: Interval(startInterval, endInterval, curve: Curves.easeOutCubic))
       ));
       
       startInterval += 0.1;
    }

    _mainController.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    final role = prefs.getString('user_role') ?? 'patient';

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => role == 'doctor'
            ? const DoctorShell()
            : const MainNavigationScreen(),
      ),
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
                        )
                      ]
                    ),
                    child: _buildLogoWidget(),
                  ),
                ),
                const SizedBox(height: 24),
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
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildLogoWidget() {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [Color(0xFF3A1A00), Color(0xFF000000)]),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.orangeAccent.withValues(alpha: 0.4), width: 1.5),
            ),
          ),
          CustomPaint(
            size: const Size(50, 30),
            painter: _PulsePainter(),
          ),
        ],
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
    path.lineTo(size.width * 0.3, 0);
    path.lineTo(size.width * 0.4, size.height);
    path.lineTo(size.width * 0.5, size.height / 2);
    path.lineTo(size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
