import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyoid_app/core/theme/app_theme.dart';
import 'package:hyoid_app/features/patient/data/models/lab_test_model.dart';
import 'package:hyoid_app/core/state/globals.dart';

class LabReportScreen extends StatefulWidget {
  final LabReport report;

  const LabReportScreen({super.key, required this.report});

  @override
  State<LabReportScreen> createState() => _LabReportScreenState();
}

class _LabReportScreenState extends State<LabReportScreen> {
  late LabReport _report;

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  Future<void> _shareReport() async {
    final text = StringBuffer();
    text.writeln('Lab Report: ${_report.title}');
    text.writeln('Provider: ${_report.provider}');
    text.writeln('Date: ${_report.requestedAt.toLocal()}');
    text.writeln('Total Amount: ₹${_report.amount}');
    text.writeln('Status: ${_report.status}');
    text.writeln('Results:');
    for (final item in _report.results) {
      text.writeln('- ${item.name}: ${item.result} (Normal: ${item.normalRange})');
    }
    await Clipboard.setData(ClipboardData(text: text.toString()));

    final updated = _report.copyWith(sharedWithDoctor: true);
    final reports = globalLabReports.value.map((entry) {
      return entry.id == _report.id ? updated : entry;
    }).toList();
    globalLabReports.value = reports;
    setState(() => _report = updated);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Report copied to clipboard and shared with your doctor.'),
      backgroundColor: AppTheme.successGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Lab Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.borderCol, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_report.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 10),
                Text('Provider: ${_report.provider}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 6),
                Text('Requested: ${_report.requestedAt.toLocal()}', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.orangeAccent.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
                      child: Text(_report.status, style: const TextStyle(color: AppTheme.orangeAccent, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Text('₹${_report.amount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    if (_report.sharedWithDoctor)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppTheme.successGreen.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
                        child: const Text('Shared', style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Test Results', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 14),
                ..._report.results.map((result) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.pureBlack,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderCol),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(result.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text('Result: ${result.result}', style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text('Normal Range: ${result.normalRange}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _shareReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(_report.sharedWithDoctor ? 'Share Again' : 'Share with Doctor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
