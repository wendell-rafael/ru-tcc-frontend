import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum InsightType {
  students,
  changedDishes,
  changesOverTime,
}

class AdminDashboardInsightsScreen extends StatefulWidget {
  const AdminDashboardInsightsScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardInsightsScreenState createState() =>
      _AdminDashboardInsightsScreenState();
}

class _AdminDashboardInsightsScreenState
    extends State<AdminDashboardInsightsScreen> {
  InsightType selectedInsight = InsightType.students;
  final Color orangeColor = const Color(0xFFE65100);

  // -----------------------------------------------------------
  // 1. Dados de alunos
  // Realiza 3 queries para obter total, veganos e vegetarianos.
  Future<Map<String, int>> _getStudentData() async {
    final firestore = FirebaseFirestore.instance;
    final totalSnapshot = await firestore.collection('users').get();
    final total = totalSnapshot.size;
    final veganSnapshot = await firestore
        .collection('users')
        .where('dietaryRestriction', isEqualTo: 'Vegano')
        .get();
    final veganos = veganSnapshot.size;
    final vegetarianSnapshot = await firestore
        .collection('users')
        .where('dietaryRestriction', isEqualTo: 'Vegetariano')
        .get();
    final vegetarian = vegetarianSnapshot.size;
    final others = total - (veganos + vegetarian);
    return {'total': total, 'veganos': veganos, 'vegetarian': vegetarian, 'others': others};
  }

  // -----------------------------------------------------------
  // 2. Dados de pratos mudados: agrega por campo
  Future<List<ChartData>> _getChangedDishesData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cardapioChanges')
        .get();
    final Map<String, int> counts = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final changes = data['changes'] as Map<String, dynamic>? ?? {};
      for (var key in changes.keys) {
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    List<ChartData> result = counts.entries
        .map((e) => ChartData(e.key, e.value.toDouble()))
        .toList();
    result.sort((a, b) => b.value.compareTo(a.value));
    return result;
  }

  // -----------------------------------------------------------
  // 3. Alterações ao longo do tempo: agrupa por mês (para o ano corrente)
  Future<List<ChartData>> _getChangesOverTimeData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('cardapioChanges')
        .get();
    // Cria um mapa com chave "Mês/Ano" e valor a contagem
    final Map<String, int> counts = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final Timestamp ts = data['timestamp'];
      final DateTime date = ts.toDate();
      // Aqui usamos o mês/ano; você pode ajustar para usar apenas mês se desejar
      final key = "${date.month}/${date.year}";
      counts[key] = (counts[key] ?? 0) + 1;
    }
    List<ChartData> result = counts.entries
        .map((e) => ChartData(e.key, e.value.toDouble()))
        .toList();
    result.sort((a, b) {
      // Ordena por data
      final partsA = a.label.split('/');
      final partsB = b.label.split('/');
      final monthA = int.tryParse(partsA[0]) ?? 0;
      final yearA = int.tryParse(partsA[1]) ?? 0;
      final monthB = int.tryParse(partsB[0]) ?? 0;
      final yearB = int.tryParse(partsB[1]) ?? 0;
      final dateA = DateTime(yearA, monthA);
      final dateB = DateTime(yearB, monthB);
      return dateA.compareTo(dateB);
    });
    return result;
  }

  // Widget que exibe o gráfico de acordo com o insight selecionado
  Widget _buildInsightChart() {
    switch (selectedInsight) {
      case InsightType.students:
        return FutureBuilder<Map<String, int>>(
          future: _getStudentData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final data = snapshot.data!;
            final pieData = <PieChartData>[
              PieChartData('Veganos', data['veganos']!.toDouble()),
              PieChartData('Vegetarianos', data['vegetarian']!.toDouble()),
              PieChartData('Outros', data['others']!.toDouble()),
            ];
            return SfCircularChart(
              title: ChartTitle(
                text: 'Distribuição de Alunos',
                textStyle: TextStyle(color: orangeColor, fontWeight: FontWeight.bold),
              ),
              legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              series: <CircularSeries>[
                PieSeries<PieChartData, String>(
                  dataSource: pieData,
                  xValueMapper: (PieChartData data, _) => data.category,
                  yValueMapper: (PieChartData data, _) => data.value,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                  explode: true,
                  explodeIndex: 0,
                  pointColorMapper: (PieChartData data, _) {
                    if (data.category == 'Veganos') return Colors.green;
                    if (data.category == 'Vegetarianos') return Colors.lime;
                    return Colors.grey;
                  },
                )
              ],
            );
          },
        );
      case InsightType.changedDishes:
        return FutureBuilder<List<ChartData>>(
          future: _getChangedDishesData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final chartData = snapshot.data!;
            return SfCartesianChart(
              title: ChartTitle(
                text: 'Campos Mais Alterados',
                textStyle: TextStyle(color: orangeColor, fontWeight: FontWeight.bold),
              ),
              primaryXAxis: CategoryAxis(
                labelRotation: -45,
                labelStyle: const TextStyle(fontSize: 10),
              ),
              primaryYAxis: NumericAxis(
                interval: 1,
                labelStyle: const TextStyle(fontSize: 10),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries>[
                ColumnSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  color: orangeColor,
                )
              ],
            );
          },
        );
      case InsightType.changesOverTime:
        return FutureBuilder<List<ChartData>>(
          future: _getChangesOverTimeData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final chartData = snapshot.data!;
            return SfCartesianChart(
              title: ChartTitle(
                text: 'Alterações ao Longo do Tempo',
                textStyle: TextStyle(color: orangeColor, fontWeight: FontWeight.bold),
              ),
              primaryXAxis: CategoryAxis(
                labelRotation: -45,
                labelStyle: const TextStyle(fontSize: 10),
              ),
              primaryYAxis: NumericAxis(
                interval: 1,
                labelStyle: const TextStyle(fontSize: 10),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries>[
                LineSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                  markerSettings: const MarkerSettings(isVisible: true),
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  color: orangeColor,
                )
              ],
            );
          },
        );
      default:
        return const SizedBox();
    }
  }

  // Dropdown para selecionar o tipo de insight
  Widget _buildInsightSelector() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: orangeColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: orangeColor.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insights, color: Colors.black87),
            const SizedBox(width: 8),
            DropdownButton<InsightType>(
              underline: Container(),
              value: selectedInsight,
              icon: Icon(Icons.arrow_drop_down, color: orangeColor),
              items: [
                DropdownMenuItem(
                  value: InsightType.students,
                  child: Text("Alunos", style: TextStyle(color: orangeColor)),
                ),
                DropdownMenuItem(
                  value: InsightType.changedDishes,
                  child: Text("Pratos Mudados", style: TextStyle(color: orangeColor)),
                ),
                DropdownMenuItem(
                  value: InsightType.changesOverTime,
                  child: Text("Alterações no Tempo", style: TextStyle(color: orangeColor)),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedInsight = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights do Cardápio"),
        backgroundColor: orangeColor,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildInsightSelector(),
          Expanded(
            child: _buildInsightChart(),
          ),
        ],
      ),
    );
  }
}

class PieChartData {
  final String category;
  final double value;
  PieChartData(this.category, this.value);
}

class ChartData {
  final String label;
  final double value;
  ChartData(this.label, this.value);
}
