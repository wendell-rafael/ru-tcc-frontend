import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum InsightType {
  students,
  changedDishes,
  changesByMeal,
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

  // 1. Dados de alunos
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
    return {
      'total': total,
      'veganos': veganos,
      'vegetarian': vegetarian,
      'others': others
    };
  }

  // 2. Dados de pratos mudados: agrega alterações por campo
  Future<List<ChartData>> _getChangedDishesData() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('cardapioChanges').get();
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

  // 3. Dados de alterações por refeição: agrupa os documentos pelo campo "refeicao"
  Future<List<PieChartData>> _getChangesByMealData() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('cardapioChanges').get();
    final Map<String, int> counts = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      // Supondo que o documento possua um campo "refeicao"
      final refeicao = data['refeicao'] as String? ?? 'Indefinido';
      counts[refeicao] = (counts[refeicao] ?? 0) + 1;
    }
    List<PieChartData> result = counts.entries
        .map((e) => PieChartData(e.key, e.value.toDouble()))
        .toList();
    result.sort((a, b) => b.value.compareTo(a.value));
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
                textStyle: TextStyle(
                    color: orangeColor, fontWeight: FontWeight.bold),
              ),
              legend:
              Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              series: <CircularSeries>[
                PieSeries<PieChartData, String>(
                  dataSource: pieData,
                  xValueMapper: (PieChartData data, _) => data.category,
                  yValueMapper: (PieChartData data, _) => data.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
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
                textStyle:
                TextStyle(color: orangeColor, fontWeight: FontWeight.bold),
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
      case InsightType.changesByMeal:
        return FutureBuilder<List<PieChartData>>(
          future: _getChangesByMealData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final pieData = snapshot.data!;
            return SfCircularChart(
              title: ChartTitle(
                text: 'Alterações por Refeição',
                textStyle:
                TextStyle(color: orangeColor, fontWeight: FontWeight.bold),
              ),
              legend:
              Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              series: <CircularSeries>[
                PieSeries<PieChartData, String>(
                  dataSource: pieData,
                  xValueMapper: (PieChartData data, _) => data.category,
                  yValueMapper: (PieChartData data, _) => data.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  explode: true,
                  explodeIndex: 0,
                  pointColorMapper: (PieChartData data, _) {
                    // Podemos definir cores específicas para cada refeição se desejar
                    if (data.category.toLowerCase().contains("almoço")) {
                      return orangeColor;
                    } else if (data.category.toLowerCase().contains("jantar")) {
                      return Colors.deepOrange;
                    }
                    return Colors.grey;
                  },
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
                  value: InsightType.changesByMeal,
                  child:
                  Text("Alterações por Refeição", style: TextStyle(color: orangeColor)),
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
          Expanded(child: _buildInsightChart()),
        ],
      ),
    );
  }
}
