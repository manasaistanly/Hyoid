import 'package:flutter/material.dart';
import 'package:hyoid_app/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:math';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  late IO.Socket socket;
  final List<FlSpot> _ecgData = [];
  double _time = 0;

  String heartRate = "--";
  String spO2 = "--";
  String temp = "--";

  @override
  void initState() {
    super.initState();
    _initSocket();
    _mockEcgData();
  }

  void _initSocket() {
    socket = IO.io(
      'http://10.0.2.2:5000/vitals',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    socket.connect();
    socket.on('vitals_update', (data) {
      if (mounted) {
        setState(() {
          heartRate = data['heartRate'].toString();
          spO2 = data['spO2'].toString();
          temp = data['temperature'].toString();
        });
      }
    });
  }

  void _mockEcgData() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return false;

      setState(() {
        _time += 0.1;
        // Simple ECG math mock
        double y = sin(_time * 5) * 0.5;
        if (_time % 2 < 0.2) {
          y += 5.0; // Spike
        } else if (_time % 2 < 0.4)
          y -= 1.0;

        _ecgData.add(FlSpot(_time, y));
        if (_ecgData.length > 50) _ecgData.removeAt(0);
      });
      return true;
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Live Vitals",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("ECG Status", style: TextStyle(color: Colors.white70)),
                    Icon(Icons.circle, color: AppTheme.successGreen, size: 12),
                  ],
                ),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _ecgData,
                          isCurved: true,
                          color: AppTheme.successGreen,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                      minY: -2,
                      maxY: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              _buildBigVitalCard(
                "Heart Rate",
                heartRate,
                "bpm",
                AppTheme.dangerRed,
              ),
              const SizedBox(width: 16),
              _buildBigVitalCard("SpO2", spO2, "%", Colors.blue),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBigVitalCard(
                "Temperature",
                temp,
                "°F",
                AppTheme.warningOrange,
              ),
              const SizedBox(width: 16),
              _buildBigVitalCard("Glucose", "110", "mg/dL", Colors.purple),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBigVitalCard(
    String title,
    String value,
    String unit,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
