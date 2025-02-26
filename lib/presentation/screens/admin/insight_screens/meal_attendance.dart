import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MealAttendanceScreen extends StatelessWidget {
  final Color orangeColor = const Color(0xFFE65100);

  Future<List<_ChartData>> _getMealAttendanceComparison() async {
    final snapshot = await FirebaseFirestore.instance.collection('checkins').get();
    final Map<String, int> counts = {'Almoço': 0, 'Jantar': 0};

    for (var doc in snapshot.docs) {
      DateTime checkinTime = (doc['timestamp'] as Timestamp).toDate();
      if (checkinTime.hour < 15) {
        counts['Almoço'] = (counts['Almoço'] ?? 0) + 1;
      } else {
        counts['Jantar'] = (counts['Jantar'] ?? 0) + 1;
      }
    }

    return counts.entries.map((e) => _ChartData(e.key, e.value)).toList();
  }

  int _calculateInterval(List<_ChartData> data) {
    int maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return (maxValue / 5).ceil().clamp(1, 10); // 🔥 Ajusta dinamicamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🏆 Almoço vs Jantar"), backgroundColor: orangeColor),
      body: FutureBuilder<List<_ChartData>>(
        future: _getMealAttendanceComparison(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          int interval = _calculateInterval(snapshot.data!);

          return SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(minimum: 0, interval: interval.toDouble()),
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
