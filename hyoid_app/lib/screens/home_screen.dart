import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/screens/services_hub_screen.dart';
import 'package:hyoid_app/screens/live_tracking_screen.dart';
import 'package:hyoid_app/screens/notifications_screen.dart';
import 'package:hyoid_app/globals.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentRecordIndex = 0;
  Timer? _animTimer;
  
  // Simulating an empty records payload
  final List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _animTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _records.isNotEmpty) {
        setState(() {
          _currentRecordIndex = (_currentRecordIndex + 1) % _records.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _animTimer?.cancel();
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
                  color: AppTheme.orangeAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.orangeAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
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
          
          // Featured Banners
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildHeroCard(
                  "Get Expert\nCare Anywhere", 
                  "https://images.unsplash.com/photo-1579684385127-1ef15d508118?q=80&w=600&auto=format&fit=crop",
                ),
                _buildHeroCard(
                  "Doorstep\nDiagnostics", 
                  "https://images.unsplash.com/photo-1579154204601-01588f351e67?q=80&w=600&auto=format&fit=crop",
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
                child: Row(
                  children: const [
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
          
          if (_records.isEmpty)
             _buildEmptyRecordsCard()
          else
             AnimatedSwitcher(
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
               child: _buildAnimatedRecordCard(
                  key: ValueKey<int>(_currentRecordIndex),
                  record: _records[_currentRecordIndex],
               ),
             ),

          const SizedBox(height: 220), // Bottom nav & floating banner padding
        ],
      ),
      ValueListenableBuilder<bool>(
        valueListenable: globalHasActiveBooking,
        builder: (context, hasBooking, child) {
          if (!hasBooking) return const SizedBox.shrink();
          return Positioned(
            bottom: 110,
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

  Widget _buildHeroCard(String title, String imageUrl) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderCol),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(AppTheme.pureBlack.withOpacity(0.4), BlendMode.darken),
        )
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppTheme.pureBlack.withOpacity(0.9),
              Colors.transparent,
            ]
          )
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text("Explore Now", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimatedRecordCard({required Key key, required Map<String, dynamic> record}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderCol, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: record['color'].withOpacity(0.05),
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
            decoration: BoxDecoration(color: record['color'].withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(record['icon'], color: record['color'], size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(record['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(record['sub'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 6),
                Text(record['date'], style: TextStyle(color: record['color'], fontSize: 12, fontWeight: FontWeight.bold)),
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
            child: const Text("View", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
          BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 20, spreadRadius: 2)
        ]
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveTrackingScreen()));
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
                children: const [
                  Text("Arriving in 14 mins", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text("Dr. Sarah Jenkins is on the way", style: TextStyle(color: Colors.white54, fontSize: 13)),
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
