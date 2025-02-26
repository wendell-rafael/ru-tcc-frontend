import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class AttendanceTrendsScreen extends StatelessWidget {
  final Color orangeColor = const Color(0xFFE65100);

  Future<List<_ChartData>> _getAttendanceTrends() async {
    final DateTime now = DateTime.now();
    final DateTime lastWeek = now.subtract(const Duration(days: 7));

    final snapshot = await FirebaseFirestore.instance
        .collection('checkins')
        .where('timestamp_checkin', isGreaterThanOrEqualTo: lastWeek)
        .orderBy('timestamp_checkin', descending: true)
        .get();

    final Map<String, int> counts = {
      'Seg': 0, 'Ter': 0, 'Qua': 0, 'Qui': 0, 'Sex': 0
    };

    for (var doc in snapshot.docs) {
      final DateTime checkinDate = (doc['timestamp_checkin'] as Timestamp).toDate();
      String day = DateFormat('E', 'pt_BR').format(checkinDate); // Formata para "Seg", "Ter", etc.

      if (counts.containsKey(day)) {
        counts[day] = (counts[day] ?? 0) + 1;
      }
    }

    return counts.entries.map((e) => _ChartData(e.key, e.value)).toList();
  }

  int _calculateInterval(List<_ChartData> data) {
    if (data.isEmpty) return 1;
    int maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return (maxValue / 5).ceil().clamp(1, 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📆 Tendência de Check-ins"), backgroundColor: orangeColor),
      body: FutureBuilder<List<_ChartData>>(
        future: _getAttendanceTrends(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          double interval = _calculateInterval(snapshot.data!).toDouble();

          return SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(minimum: 0, interval: interval),
            series: <ChartSeries<_ChartData, String>>[
              ColumnSeries<_ChartData, String>(
                dataSource: snapshot.data!,
                xValueMapper: (_ChartData data, _) => data.category,
                yValueMapper: (_ChartData data, _) => data.value,
                color: orangeColor,
                dataLabelSettings: DataLabelSettings(isVisible: true),
              )
            ],
          );
        },
      ),
    );
  }
}

class _ChartData {
  final String category;
  final int value;
  _ChartData(this.category, this.value);
}
