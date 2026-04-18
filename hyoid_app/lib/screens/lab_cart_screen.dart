import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/models/lab_test_model.dart';
import 'package:hyoid_app/models/service_model.dart';
import 'package:hyoid_app/screens/live_tracking_screen.dart';
import 'package:hyoid_app/screens/services_hub_screen.dart';
import 'package:hyoid_app/globals.dart';

class LabCartScreen extends StatefulWidget {
  const LabCartScreen({super.key});

  @override
  State<LabCartScreen> createState() => _LabCartScreenState();
}

class _LabCartScreenState extends State<LabCartScreen> {
  bool _isCheckingOut = false;
  String _selectedCycle = 'one-time'; // 'one-time', 'weekly', 'monthly'

  int get _totalAmount {
    int baseAmount = globalLabCart.value.fold(0, (sum, item) => sum + item.price);
    return baseAmount;
  }

  int get _displayAmount {
    switch (_selectedCycle) {
      case 'weekly':
        return _totalAmount;
      case 'monthly':
        return (_totalAmount * 0.9).toInt(); // 10% discount for monthly
      default:
        return _totalAmount;
    }
  }

  String get _cycleLabel {
    switch (_selectedCycle) {
      case 'weekly':
        return 'Every Week';
      case 'monthly':
        return 'Every Month (10% off)';
      default:
        return 'One-time';
    }
  }

  ServiceBooking get _labBooking => ServicesHubScreen.services.firstWhere(
        (service) => service.title == 'Doorstep Lab Test',
        orElse: () => ServiceBooking(
          title: 'Doorstep Lab Test',
          subtitle: 'Sample collection delivered to your door.',
          providerName: 'Apex Diagnostics',
          specialization: 'Certified Phlebotomist • LabCorp',
          icon: Icons.science_rounded,
          color: const Color(0xFFA78BFA),
          glowColor: const Color(0x26A78BFA),
          priceFrom: 300,
        ),
      );

  Future<void> _checkout() async {
    if (globalLabCart.value.isEmpty) return;

    setState(() => _isCheckingOut = true);
    await Future.delayed(const Duration(seconds: 2));

    final report = LabReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Doorstep Lab Test Report',
      provider: _labBooking.providerName,
      requestedAt: DateTime.now(),
      status: 'Sample collector is on the way',
      amount: _totalAmount,
      results: globalLabCart.value
          .map((item) => LabReportItem(
                name: item.title,
                result: 'Pending',
                normalRange: 'Please collect sample',
              ))
          .toList(),
    );

    globalLabReports.value = [report, ...globalLabReports.value];
    globalLabCart.value = [];
    globalActiveBooking = _labBooking;
    globalHasActiveBooking.value = true;

    if (!mounted) return;
    setState(() => _isCheckingOut = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LiveTrackingScreen(booking: _labBooking)),
    );
  }

  void _removeItem(LabTest item) {
    final newCart = List<LabTest>.from(globalLabCart.value)..removeWhere((element) => element.id == item.id);
    globalLabCart.value = newCart;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Lab Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
      ),
      body: ValueListenableBuilder<List<LabTest>>(
        valueListenable: globalLabCart,
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 72, color: Colors.white24),
                    const SizedBox(height: 18),
                    const Text('Your lab cart is empty', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Add available tests from the lab catalog to schedule collection and generate your report.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
            itemCount: cart.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = cart[index];
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF2E2E2E), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: item.color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 6),
                          Text(item.description, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Specimen: ${item.specimen}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('₹${item.price}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeItem(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFF222222),
                        ),
                        child: const Text('Remove', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<List<LabTest>>(
        valueListenable: globalLabCart,
        builder: (context, cart, _) {
          if (cart.isEmpty) return const SizedBox.shrink();
          return SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2E2E2E), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 12)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Payment Cycle', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCycleButton('one-time', 'One-Time', 'Pay once'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCycleButton('weekly', 'Weekly', 'Recurring'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCycleButton('monthly', 'Monthly', 'Save 10%'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Amount to Pay', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          Text('₹$_displayAmount', style: const TextStyle(color: AppTheme.orangeAccent, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_cycleLabel, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.orangeAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Sample Collection Included', style: TextStyle(color: AppTheme.orangeAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isCheckingOut ? null : _checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.orangeAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                      ),
                      child: _isCheckingOut
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Pay & Schedule Collection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Our phlebotomist will collect sample at your home', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCycleButton(String cycle, String label, String subtitle) {
    final isSelected = _selectedCycle == cycle;
    return GestureDetector(
      onTap: () => setState(() => _selectedCycle = cycle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.orangeAccent.withOpacity(0.18) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.orangeAccent : const Color(0xFF2E2E2E),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: isSelected ? AppTheme.orangeAccent : Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: isSelected ? AppTheme.orangeAccent.withOpacity(0.8) : Colors.white54, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
