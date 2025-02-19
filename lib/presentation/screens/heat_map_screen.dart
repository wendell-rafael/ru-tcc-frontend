import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class IntervalData {
  final String intervalLabel;
  final int count;
  IntervalData({required this.intervalLabel, required this.count});
}

class HeatMapScreen extends StatefulWidget {
  @override
  _HeatMapScreenState createState() => _HeatMapScreenState();
}

class _HeatMapScreenState extends State<HeatMapScreen> {
  List<IntervalData> lunchData = [];
  List<IntervalData> dinnerData = [];

  @override
  void initState() {
    super.initState();
    fetchCheckins();
  }

  List<DateTime> getLunchIntervals(DateTime date) {
    List<DateTime> intervals = [];
    DateTime start = DateTime(date.year, date.month, date.day, 10, 30);
    DateTime end = DateTime(date.year, date.month, date.day, 14, 0);
    while (start.isBefore(end)) {
      intervals.add(start);
      start = start.add(Duration(minutes: 20));
    }
    return intervals;
  }

  List<DateTime> getDinnerIntervals(DateTime date) {
    List<DateTime> intervals = [];
    DateTime start = DateTime(date.year, date.month, date.day, 17, 0);
    DateTime end = DateTime(date.year, date.month, date.day, 19, 30);
    while (start.isBefore(end)) {
      intervals.add(start);
      start = start.add(Duration(minutes: 20));
    }
    return intervals;
  }

  Future<void> fetchCheckins() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('checkins')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .get();

    Map<String, int> lunchCounts = {};
    Map<String, int> dinnerCounts = {};
    DateFormat formatter = DateFormat.Hm();

    List<DateTime> lunchList = getLunchIntervals(now);
    List<DateTime> dinnerList = getDinnerIntervals(now);

    // Inicializa com zero
    for (var dt in lunchList) {
      lunchCounts[formatter.format(dt)] = 0;
    }
    for (var dt in dinnerList) {
      dinnerCounts[formatter.format(dt)] = 0;
    }

    // Agrupa cada check-in no intervalo correspondente
    for (var doc in snapshot.docs) {
      Timestamp ts = doc.get('timestamp');
      DateTime checkinTime = ts.toDate();
      // Almoço
      if (checkinTime.isAfter(DateTime(now.year, now.month, now.day, 10, 30)) &&
          checkinTime.isBefore(DateTime(now.year, now.month, now.day, 14, 0))) {
        for (var dt in lunchList) {
          DateTime intervalEnd = dt.add(Duration(minutes: 20));
          if (!checkinTime.isBefore(dt) && checkinTime.isBefore(intervalEnd)) {
            String key = formatter.format(dt);
            lunchCounts[key] = (lunchCounts[key] ?? 0) + 1;
            break;
          }
        }
      }
      // Jantar
      if (checkinTime.isAfter(DateTime(now.year, now.month, now.day, 17, 0)) &&
          checkinTime.isBefore(DateTime(now.year, now.month, now.day, 19, 30))) {
        for (var dt in dinnerList) {
          DateTime intervalEnd = dt.add(Duration(minutes: 20));
          if (!checkinTime.isBefore(dt) && checkinTime.isBefore(intervalEnd)) {
            String key = formatter.format(dt);
            dinnerCounts[key] = (dinnerCounts[key] ?? 0) + 1;
            break;
          }
        }
      }
    }

    List<IntervalData> lunchResults = [];
    List<String> lunchKeys = lunchCounts.keys.toList()
      ..sort((a, b) {
        DateTime timeA = formatter.parse(a);
        DateTime timeB = formatter.parse(b);
        return timeA.compareTo(timeB);
      });
    for (var key in lunchKeys) {
      lunchResults.add(IntervalData(intervalLabel: key, count: lunchCounts[key]!));
    }

    List<IntervalData> dinnerResults = [];
    List<String> dinnerKeys = dinnerCounts.keys.toList()
      ..sort((a, b) {
        DateTime timeA = formatter.parse(a);
        DateTime timeB = formatter.parse(b);
        return timeA.compareTo(timeB);
      });
    for (var key in dinnerKeys) {
      dinnerResults.add(IntervalData(intervalLabel: key, count: dinnerCounts[key]!));
    }

    setState(() {
      lunchData = lunchResults;
      dinnerData = dinnerResults;
    });
  }

  // Define a cor de cada coluna com base na contagem
  Color getColor(int count) {
    if (count == 0) return Colors.grey.shade200;
    if (count < 3) return Colors.orange.shade200;
    if (count < 5) return Colors.orange;
    return Colors.red;
  }

  Widget buildChart(String title, List<IntervalData> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100))),
        SizedBox(height: 8),
        Container(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(minimum: 0, interval: 1),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries>[
              ColumnSeries<IntervalData, String>(
                dataSource: data,
                xValueMapper: (IntervalData d, _) => d.intervalLabel,
                yValueMapper: (IntervalData d, _) => d.count,
                pointColorMapper: (IntervalData d, _) => getColor(d.count),
                dataLabelSettings: DataLabelSettings(isVisible: true),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa de Calor de Check-ins"),
        backgroundColor: Color(0xFFE65100),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildChart("Almoço (10:30 - 14:00)", lunchData),
            SizedBox(height: 20),
            buildChart("Jantar (17:00 - 19:30)", dinnerData),
          ],
        ),
      ),
    );
  }
}
