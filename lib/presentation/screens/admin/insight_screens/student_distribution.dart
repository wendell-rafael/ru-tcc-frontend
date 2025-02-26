import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StudentDistributionScreen extends StatelessWidget {
  final Color orangeColor = const Color(0xFFE65100);

  Future<List<_ChartData>> _getStudentData() async {
    final firestore = FirebaseFirestore.instance;
    final totalSnapshot = await firestore.collection('users').get();
    final veganSnapshot = await firestore.collection('users').where('dietaryRestriction', isEqualTo: 'Vegano').get();
    final vegetarianSnapshot = await firestore.collection('users').where('dietaryRestriction', isEqualTo: 'Vegetariano').get();

    return [
      _ChartData('Veganos', veganSnapshot.size.toDouble()),
      _ChartData('Vegetarianos', vegetarianSnapshot.size.toDouble()),
      _ChartData('Flexitarianos', (totalSnapshot.size - (veganSnapshot.size + vegetarianSnapshot.size)).toDouble()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📊 Distribuição de Alunos"), backgroundColor: orangeColor),
      body: FutureBuilder<List<_ChartData>>(
        future: _getStudentData(),
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
