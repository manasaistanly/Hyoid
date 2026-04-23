import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyoid_app/core/state/globals.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/patient/presentation/screens/services_hub_screen.dart';
import 'package:hyoid_app/features/patient/presentation/screens/live_tracking_screen.dart';
import 'package:hyoid_app/features/patient/presentation/screens/lab_report_screen.dart';
import 'package:hyoid_app/features/patient/data/models/lab_test_model.dart';
import 'package:hyoid_app/features/patient/presentation/screens/notifications_screen.dart';

class CarouselSlide {
  final String imageUrl;
  final String? assetPath; // optional local asset, overrides imageUrl when set
  final String title;
  final String subtitle;
  final String badge;
  final String ctaText;

  const CarouselSlide({
    required this.imageUrl,
    this.assetPath,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.ctaText,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? _carouselController;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  final List<CarouselSlide> _carouselSlides = [
    const CarouselSlide(
      imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=800&auto=format&fit=crop',
      title: 'Expert Care\nAnywhere',
      subtitle: 'Connect with top specialists instantly',
      badge: 'FEATURED',
      ctaText: 'Book Now',
    ),
    const CarouselSlide(
      imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=800&auto=format&fit=crop',
      title: '24/7 Nursing\nSupport',
      subtitle: 'Professional care at your doorstep',
      badge: 'POPULAR',
      ctaText: 'Get Care',
    ),
    const CarouselSlide(
      imageUrl: '',
      assetPath: 'assets/images/diagnostics_hero.png',
      title: 'Advanced\nDiagnostics',
      subtitle: 'Accurate results from home',
      badge: 'NEW',
      ctaText: 'Test Now',
    ),
    const CarouselSlide(
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=800&auto=format&fit=crop',
      title: 'Express\nPharmacy',
      subtitle: 'Medications delivered fast',
      badge: 'FAST',
      ctaText: 'Order Now',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(viewportFraction: 0.9);
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _carouselController!.hasClients) {
        final nextPage = (_currentCarouselIndex + 1) % _carouselSlides.length;
        _carouselController!.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.monitor_heart, color: AppTheme.orangeAccent, size: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.orangeAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.orangeAccent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stars_rounded, color: AppTheme.orangeAccent, size: 16),
                    SizedBox(width: 4),
                    Text("Premium", style: TextStyle(color: AppTheme.orangeAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: globalNotifCount,
                builder: (context, count, _) {
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppTheme.darkSurface,
                          child: Icon(Icons.notifications_outlined, color: Colors.white),
                        ),
                        if (count > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.dangerRed,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Hero Carousel
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _carouselController,
                  onPageChanged: (index) {
                    setState(() => _currentCarouselIndex = index);
                  },
                  itemCount: _carouselSlides.length,
                  itemBuilder: (context, index) {
                    final slide = _carouselSlides[index];
                    return AnimatedBuilder(
                      animation: _carouselController!,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_carouselController!.position.haveDimensions) {
                          value = _carouselController!.page! - index;
                          value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                        }
                        return Transform.scale(
                          scale: value * 0.08 + 0.92, // scale from 0.92 to 1.0
                          child: child,
                        );
                      },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: slide.assetPath != null
                                  ? AssetImage(slide.assetPath!) as ImageProvider
                                  : NetworkImage(slide.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Stack(
                            children: [
                              // Badge
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF5722),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    slide.badge,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Content
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slide.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    slide.subtitle,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF5722),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      slide.ctaText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Indicators
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _carouselSlides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentCarouselIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentCarouselIndex == index
                              ? const Color(0xFFFF5722)
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Anchor Tag -> Book Now
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Our Services", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesHubScreen()));
                },
                child: const Row(
                  children: [
                    Text("Book Now", style: TextStyle(color: AppTheme.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, color: AppTheme.orangeAccent, size: 14),
                  ],
                ),
              )
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Animated Previous Records
          const Text("Recent Records", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          
          ValueListenableBuilder<List<LabReport>>(
            valueListenable: globalLabReports,
            builder: (context, reports, _) {
              if (reports.isEmpty) {
                return _buildEmptyRecordsCard();
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(CurvedAnimation(
                        parent: animation, 
                        curve: Curves.easeOutBack
                      )),
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  key: ValueKey<String>(reports.first.id),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => LabReportScreen(report: reports.first)));
                  },
                  child: _buildLabReportCard(report: reports.first),
                ),
              );
            },
          ),

          const SizedBox(height: 220), // Bottom nav & floating banner padding
        ],
      ),
      ValueListenableBuilder<bool>(
        valueListenable: globalHasActiveBooking,
        builder: (context, hasBooking, child) {
          if (!hasBooking) return const SizedBox.shrink();
          return Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: _buildActiveTrackingBanner(context),
          );
        },
      ),
    ],
  ),
);
  }

  Widget _buildLabReportCard({required LabReport report}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderCol, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.orangeAccent.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.orangeAccent.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.folder_shared, color: AppTheme.orangeAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(report.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Provider: ${report.provider}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 6),
                Text('Generated on ${report.requestedAt.toLocal()}', style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.pureBlack,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderCol)
            ),
            child: const Text('View', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyRecordsCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderCol, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 20, spreadRadius: 2)
        ]
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: const Icon(Icons.folder_open, color: Colors.white54, size: 36),
            ),
            const SizedBox(height: 16),
            const Text("No Recent Records", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "You don't have any medical history logged locally. Book a service to get started.", 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.white54, fontSize: 14)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTrackingBanner(BuildContext context) {
    final booking = globalActiveBooking;
    return GestureDetector(
      onTap: () {
        if (booking == null) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => LiveTrackingScreen(booking: booking)));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.orangeAccent.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.orangeAccent.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Row(
          children: [
            // Pulsing marker
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppTheme.successGreen,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.successGreen, blurRadius: 8, spreadRadius: 2)]
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Arriving in 14 mins", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("${globalActiveBooking?.providerName ?? 'Your provider'} is on the way", style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.orangeAccent, size: 16),
          ],
        ),
      ),
    );
  }
}
