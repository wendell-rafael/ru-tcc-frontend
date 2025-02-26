import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FeedbacksScreen extends StatelessWidget {
  final Color orangeColor = const Color(0xFFE65100);

  Future<List<_ChartData>> _getFeedbackData() async {
    final snapshot = await FirebaseFirestore.instance.collection('avaliacoes').get();
    int positivos = 0;
    int negativos = 0;

    for (var doc in snapshot.docs) {
      final score = doc['avaliacao'] ?? 3; // Supondo que a nota vai de 1 a 5
      if (score >= 4) {
        positivos++;
      } else {
        negativos++;
      }
    }

    return [
      _ChartData('Positivos', positivos.toDouble()),
      _ChartData('Negativos', negativos.toDouble()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("⭐ Feedbacks de Alunos"), backgroundColor: orangeColor),
      body: FutureBuilder<List<_ChartData>>(
        future: _getFeedbackData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return SfCircularChart(
            legend: Legend(isVisible: true),
            series: <CircularSeries>[
              PieSeries<_ChartData, String>(
                dataSource: snapshot.data!,
                xValueMapper: (_ChartData data, _) => data.category,
                yValueMapper: (_ChartData data, _) => data.value,
                dataLabelSettings: DataLabelSettings(isVisible: true),
                explode: true,
                explodeIndex: 0,
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
  final double value;
  _ChartData(this.category, this.value);
}
