import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:hyoid_app/screens/live_tracking_screen.dart';
import 'package:hyoid_app/globals.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedDate = 0;
  int _selectedSlot = -1;

  final List<String> slots = ["09:00 AM", "10:00 AM", "11:30 AM", "01:00 PM", "03:00 PM", "04:30 PM"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Book Appointment", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderCol)),
              child: Row(
                children: [
                  const CircleAvatar(radius: 25, backgroundColor: AppTheme.borderCol, child: Icon(Icons.person, color: Colors.white)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Dr. Sarah Jenkins", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Cardiologist • Generic Hosp", style: TextStyle(color: Colors.white54, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Select Date", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 14,
              itemBuilder: (context, index) {
                bool isSelected = _selectedDate == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.orangeAccent : AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? AppTheme.orangeAccent : AppTheme.borderCol),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Mon", style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("${12 + index}", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 30),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Available Slots", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: slots.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedSlot == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.orangeAccent : AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppTheme.orangeAccent : AppTheme.borderCol),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          slots[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20).copyWith(bottom: 100),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedSlot != -1 ? () {
                  globalHasActiveBooking.value = true;
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveTrackingScreen()));
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  disabledBackgroundColor: AppTheme.darkSurface,
                ),
                child: const Text("Confirm Booking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
