import 'package:flutter/material.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/patient/data/models/lab_test_model.dart';
import 'package:hyoid_app/core/state/globals.dart';
import 'package:hyoid_app/features/patient/presentation/screens/lab_cart_screen.dart';

class LabCatalogScreen extends StatefulWidget {
  const LabCatalogScreen({super.key});

  @override
  State<LabCatalogScreen> createState() => _LabCatalogScreenState();
}

class _LabCatalogScreenState extends State<LabCatalogScreen> {
  final List<LabTest> _availableTests = [
    LabTest(
      id: 'cbc',
      title: 'Complete Blood Count',
      description: 'Hemoglobin, RBC, WBC and platelet profile.',
      specimen: 'Blood',
      price: 420,
      icon: Icons.bloodtype_rounded,
      color: const Color(0xFF9D4EDD),
    ),
    LabTest(
      id: 'lipid',
      title: 'Lipid Profile',
      description: 'Cholesterol, HDL, LDL and triglycerides.',
      specimen: 'Blood',
      price: 550,
      icon: Icons.favorite_rounded,
      color: const Color(0xFF4ADE80),
    ),
    LabTest(
      id: 'thyroid',
      title: 'Thyroid Panel',
      description: 'TSH, T3, T4 levels for metabolic health.',
      specimen: 'Blood',
      price: 480,
      icon: Icons.bolt_rounded,
      color: const Color(0xFFF59E0B),
    ),
    LabTest(
      id: 'bpsugar',
      title: 'Blood Sugar Test',
      description: 'Fasting and post-meal glucose readings.',
      specimen: 'Blood',
      price: 320,
      icon: Icons.monitor_heart_rounded,
      color: const Color(0xFF60A5FA),
    ),
    LabTest(
      id: 'screen',
      title: 'Full Body Screening',
      description: 'Comprehensive health markers and wellness panel.',
      specimen: 'Blood + Urine',
      price: 980,
      icon: Icons.health_and_safety_rounded,
      color: const Color(0xFFFB7185),
    ),
  ];

  void _toggleCart(LabTest test) {
    final current = List<LabTest>.from(globalLabCart.value);
    final existingIndex = current.indexWhere((item) => item.id == test.id);
    if (existingIndex >= 0) {
      current.removeAt(existingIndex);
    } else {
      current.add(test);
    }
    globalLabCart.value = current;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        title: const Text('Doorstep Lab Tests', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          ValueListenableBuilder<List<LabTest>>(
            valueListenable: globalLabCart,
            builder: (context, cart, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LabCartScreen())),
                  ),
                  if (cart.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppTheme.orangeAccent, shape: BoxShape.circle),
                        child: Text(
                          '${cart.length}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _availableTests.length,
        itemBuilder: (context, index) {
          final test = _availableTests[index];
          return ValueListenableBuilder<List<LabTest>>(
            valueListenable: globalLabCart,
            builder: (context, cart, _) {
              final inCart = cart.any((item) => item.id == test.id);
              return _LabTestCard(
                test: test,
                inCart: inCart,
                onToggleCart: () => _toggleCart(test),
              );
            },
          );
        },
      ),
    );
  }
}

class _LabTestCard extends StatelessWidget {
  final LabTest test;
  final bool inCart;
  final VoidCallback onToggleCart;

  const _LabTestCard({
    required this.test,
    required this.inCart,
    required this.onToggleCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF333333), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: test.color.withOpacity(0.18),
            ),
            child: Icon(test.icon, size: 28, color: test.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(test.description, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                const SizedBox(height: 8),
                Text('Specimen: ${test.specimen}', style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${test.price}', style: TextStyle(color: test.color, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onToggleCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: inCart ? AppTheme.successGreen : test.color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(inCart ? 'Remove' : 'Add', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
