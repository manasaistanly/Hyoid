import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hyoid_app/features/doctor/shell/doctor_shell.dart'
    show kDoctorBlue;
import 'package:hyoid_app/core/theme/app_theme.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mock availability rules (mirrors GET /api/doctor/availability)
  final List<Map<String, dynamic>> _rules = [
    {
      'id': 'rule_001',
      'dayOfWeek': 1,
      'startTime': '09:00',
      'endTime': '17:00',
      'slotDuration': 30,
    },
    {
      'id': 'rule_002',
      'dayOfWeek': 2,
      'startTime': '09:00',
      'endTime': '13:00',
      'slotDuration': 30,
    },
    {
      'id': 'rule_003',
      'dayOfWeek': 3,
      'startTime': '10:00',
      'endTime': '18:00',
      'slotDuration': 45,
    },
    {
      'id': 'rule_004',
      'dayOfWeek': 5,
      'startTime': '09:00',
      'endTime': '12:00',
      'slotDuration': 30,
    },
  ];

  // Mock blocked dates (mirrors GET /api/doctor/blocked-dates)
  final List<Map<String, dynamic>> _blockedDates = [
    {
      'id': 'block_001',
      'date': DateTime(2026, 4, 21),
      'reason': 'National Holiday',
    },
    {'id': 'block_002', 'date': DateTime(2026, 4, 25), 'reason': 'Conference'},
  ];

  final _days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool _isBlocked(DateTime day) =>
      _blockedDates.any((b) => isSameDay(b['date'] as DateTime, day));

  bool _hasRule(DateTime day) =>
      _rules.any((r) => r['dayOfWeek'] == day.weekday);

  void _deleteRule(String id) {
    setState(() => _rules.removeWhere((r) => r['id'] == id));
  }

  void _unblockDate(String id) {
    setState(() => _blockedDates.removeWhere((b) => b['id'] == id));
  }

  void _blockSelectedDate() {
    if (_selectedDay == null) return;
    if (_isBlocked(_selectedDay!)) return;
    setState(() {
      _blockedDates.add({
        'id': 'block_${DateTime.now().millisecondsSinceEpoch}',
        'date': _selectedDay!,
        'reason': 'Blocked by doctor',
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} blocked.',
        ),
        backgroundColor: AppTheme.warningOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddRuleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AvailabilityForm(
        onSave: (rule) {
          setState(() => _rules.add(rule));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Availability rule added.'),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Schedule & Availability',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          if (_selectedDay != null)
            TextButton.icon(
              onPressed: _blockSelectedDate,
              icon: const Icon(
                Icons.block_rounded,
                color: AppTheme.dangerRed,
                size: 18,
              ),
              label: const Text(
                'Block Day',
                style: TextStyle(color: AppTheme.dangerRed),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRuleSheet,
        backgroundColor: kDoctorBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Rule',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
        children: [
          // ── Calendar ─────────────────────────────────────────────
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 30)),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.week,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onPageChanged: (focused) => _focusedDay = focused,
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: Colors.white70),
              weekendTextStyle: const TextStyle(color: Colors.white70),
              outsideTextStyle: const TextStyle(color: Colors.white24),
              todayDecoration: BoxDecoration(
                color: kDoctorBlue.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: kDoctorBlue,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppTheme.dangerRed,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: Colors.white54,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: Colors.white54,
              ),
              decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              weekendStyle: TextStyle(
                color: Colors.white24,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (_isBlocked(day)) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerRed.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.dangerRed.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: AppTheme.dangerRed,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }
                if (_hasRule(day)) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kDoctorBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),

          // ── Legend ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _legend(kDoctorBlue, 'Available'),
                const SizedBox(width: 16),
                _legend(AppTheme.dangerRed, 'Blocked'),
              ],
            ),
          ),

          // ── Availability Rules ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: const Text(
              'Recurring Availability',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          if (_rules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'No availability rules set.',
                style: TextStyle(color: Colors.white38),
              ),
            )
          else
            ..._rules.map((r) => _buildRuleCard(r)),

          // ── Blocked Dates ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: const Text(
              'Blocked Dates',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          if (_blockedDates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'No blocked dates.',
                style: TextStyle(color: Colors.white38),
              ),
            )
          else
            ..._blockedDates.map((b) => _buildBlockedCard(b)),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
      ),
    ],
  );

  Widget _buildRuleCard(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDoctorBlue.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kDoctorBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: kDoctorBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _days[r['dayOfWeek'] as int],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${r['startTime']} – ${r['endTime']} · ${r['slotDuration']} min slots',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _deleteRule(r['id'] as String),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.dangerRed,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedCard(Map<String, dynamic> b) {
    final date = b['date'] as DateTime;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dangerRed.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.dangerRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.block_rounded,
              color: AppTheme.dangerRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  b['reason'] as String,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _unblockDate(b['id'] as String),
            child: const Icon(
              Icons.remove_circle_outline_rounded,
              color: AppTheme.warningOrange,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Availability Form Bottom Sheet ────────────────────────────────────────────

class AvailabilityForm extends StatefulWidget {
  final void Function(Map<String, dynamic> rule) onSave;
  const AvailabilityForm({super.key, required this.onSave});

  @override
  State<AvailabilityForm> createState() => _AvailabilityFormState();
}

class _AvailabilityFormState extends State<AvailabilityForm> {
  int _dayOfWeek = 1;
  String _startTime = '09:00';
  String _endTime = '17:00';
  int _slotDuration = 30;

  final _days = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Future<void> _pickTime(bool isStart) async {
    final parts = (isStart ? _startTime : _endTime).split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: kDoctorBlue),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isStart) {
        _startTime = formatted;
      } else {
        _endTime = formatted;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add Availability Rule',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),

          // Day selector
          const Text(
            'Day of Week',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _dayOfWeek,
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF111111),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kDoctorBlue.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kDoctorBlue.withValues(alpha: 0.3)),
              ),
            ),
            items: List.generate(7, (i) => i + 1)
                .map((d) => DropdownMenuItem(value: d, child: Text(_days[d])))
                .toList(),
            onChanged: (v) => setState(() => _dayOfWeek = v!),
          ),
          const SizedBox(height: 16),

          // Time row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start Time',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickTime(true),
                      child: _timeBox(_startTime),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End Time',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickTime(false),
                      child: _timeBox(_endTime),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Slot duration
          const Text(
            'Slot Duration (minutes)',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [15, 30, 45, 60].map((d) {
              final selected = _slotDuration == d;
              return GestureDetector(
                onTap: () => setState(() => _slotDuration = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? kDoctorBlue : const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? kDoctorBlue : const Color(0xFF333333),
                    ),
                  ),
                  child: Text(
                    '$d min',
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave({
                  'id': 'rule_${DateTime.now().millisecondsSinceEpoch}',
                  'dayOfWeek': _dayOfWeek,
                  'startTime': _startTime,
                  'endTime': _endTime,
                  'slotDuration': _slotDuration,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kDoctorBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Save Rule',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String time) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF111111),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kDoctorBlue.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.access_time_rounded, color: kDoctorBlue, size: 16),
        const SizedBox(width: 8),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}
