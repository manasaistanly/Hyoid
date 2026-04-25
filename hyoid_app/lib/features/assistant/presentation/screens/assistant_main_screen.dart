import 'package:flutter/material.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'assistant_requests_screen.dart';
import 'assistant_profile_screen.dart';

class AssistantMainScreen extends StatefulWidget {
  const AssistantMainScreen({super.key});

  @override
  State<AssistantMainScreen> createState() => _AssistantMainScreenState();
}

class _AssistantMainScreenState extends State<AssistantMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AssistantRequestsScreen(),
    const AssistantProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppTheme.pureBlack,
          selectedItemColor: Colors.tealAccent,
          unselectedItemColor: Colors.white24,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
