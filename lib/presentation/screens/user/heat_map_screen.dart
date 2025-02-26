import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

/// Modelo para representar o check-in agregado para um determinado intervalo
class PeakHourData {
  final DateTime time;     // horário de início do intervalo
  final int crowdLevel;    // total de check-ins nesse intervalo

  PeakHourData({required this.time, required this.crowdLevel});
}

class HeatMapScreen extends StatefulWidget {
  @override
  _HeatMapScreenState createState() => _HeatMapScreenState();
}

class _HeatMapScreenState extends State<HeatMapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dados agregados para cada dia (apenas dias úteis) e para cada período
  Map<String, List<PeakHourData>> lunchWeekData = {
    "SEG.": [],
    "TER.": [],
    "QUA.": [],
    "QUI.": [],
    "SEX.": [],
  };
  Map<String, List<PeakHourData>> dinnerWeekData = {
    "SEG.": [],
    "TER.": [],
    "QUA.": [],
    "QUI.": [],
    "SEX.": [],
  };

  // Labels dos dias da semana (segunda a sexta)
  final List<String> dayLabels = ["SEG.", "TER.", "QUA.", "QUI.", "SEX."];

  // Cores do app: laranja (principal) e branco (para destaque)
  final Color primaryOrange = Color(0xFFE65100);
  final Color backgroundColor = Colors.white;

  // Alterne para usar dados mock ou Firebase
  final bool useMockData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: dayLabels.length, vsync: this);
    // Define a aba inicial para o dia atual (se for fim de semana, fica na primeira aba)
    int todayWeekday = DateTime.now().weekday;
    if (todayWeekday >= 6) {
      todayWeekday = 1; // se sábado ou domingo, mostra segunda
    }
    _tabController.index = todayWeekday - 1;
    if (useMockData) {
      generateMockWeekData();
    } else {
      fetchWeekCheckins();
    }
  }

  /// Consulta os check-ins do Firestore para a semana atual (apenas segunda a sexta)
  /// e os agrupa em dois períodos:
  /// - Almoço: das 10:30 às 14:30 (4 intervalos de 1 hora)
  /// - Jantar: das 17:30 às 19:30 (2 intervalos de 1 hora)
  Future<void> fetchWeekCheckins() async {
    try {
      DateTime now = DateTime.now();
      // Calcula a segunda-feira da semana atual
      DateTime startOfWeek = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      // Para pegar somente dias úteis, consideramos apenas segunda a sexta
      DateTime endOfWeek = startOfWeek.add(Duration(days: 5));

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('checkins')
          .where('timestamp', isGreaterThanOrEqualTo: startOfWeek)
          .where('timestamp', isLessThan: endOfWeek)
          .get();

      // Estruturas para acumular os dados: chave (dia: 1 a 5) -> intervalo (label) -> contagem
      Map<int, Map<String, int>> lunchMap = {};
      Map<int, Map<String, int>> dinnerMap = {};

      for (int day = 1; day <= 5; day++) {
        lunchMap[day] = {};
        dinnerMap[day] = {};

        DateTime base = startOfWeek.add(Duration(days: day - 1));
        // Almoço: intervalos de 1 hora: 10:30, 11:30, 12:30, 13:30
        for (int i = 0; i < 4; i++) {
          DateTime intervalStart =
          DateTime(base.year, base.month, base.day, 10, 30).add(Duration(hours: i));
          String label = DateFormat.Hm().format(intervalStart);
          lunchMap[day]![label] = 0;
        }
        // Jantar: intervalos de 1 hora: 17:30, 18:30
        for (int i = 0; i < 2; i++) {
          DateTime intervalStart =
          DateTime(base.year, base.month, base.day, 17, 30).add(Duration(hours: i));
          String label = DateFormat.Hm().format(intervalStart);
          dinnerMap[day]![label] = 0;
        }
      }

      // Processa cada check-in e incrementa a contagem no intervalo correspondente
      for (var doc in snapshot.docs) {
        Timestamp ts = doc.get('timestamp');
        DateTime checkinTime = ts.toDate();
        int dayOfWeek = checkinTime.weekday;
        // Apenas processa se for dia útil (segunda a sexta: 1 a 5)
        if (dayOfWeek < 1 || dayOfWeek > 5) continue;

        // Para almoço: entre 10:30 e 14:30
        DateTime lunchStart = DateTime(checkinTime.year, checkinTime.month, checkinTime.day, 10, 30);
        DateTime lunchEnd = DateTime(checkinTime.year, checkinTime.month, checkinTime.day, 14, 30);
        if (checkinTime.isAfter(lunchStart) && checkinTime.isBefore(lunchEnd)) {
          for (var entry in lunchMap[dayOfWeek]!.entries) {
            DateTime intervalStart = DateFormat.Hm().parse(entry.key);
            intervalStart = DateTime(checkinTime.year, checkinTime.month, checkinTime.day,
                intervalStart.hour, intervalStart.minute);
            DateTime intervalEnd = intervalStart.add(Duration(hours: 1));
            if (!checkinTime.isBefore(intervalStart) && checkinTime.isBefore(intervalEnd)) {
              lunchMap[dayOfWeek]![entry.key] =
                  (lunchMap[dayOfWeek]![entry.key] ?? 0) + 1;
              break;
            }
          }
        }

        // Para jantar: entre 17:30 e 19:30
        DateTime dinnerStart =
        DateTime(checkinTime.year, checkinTime.month, checkinTime.day, 17, 30);
        DateTime dinnerEnd =
        DateTime(checkinTime.year, checkinTime.month, checkinTime.day, 19, 30);
        if (checkinTime.isAfter(dinnerStart) && checkinTime.isBefore(dinnerEnd)) {
          for (var entry in dinnerMap[dayOfWeek]!.entries) {
            DateTime intervalStart = DateFormat.Hm().parse(entry.key);
            intervalStart = DateTime(checkinTime.year, checkinTime.month, checkinTime.day,
                intervalStart.hour, intervalStart.minute);
            DateTime intervalEnd = intervalStart.add(Duration(hours: 1));
            if (!checkinTime.isBefore(intervalStart) && checkinTime.isBefore(intervalEnd)) {
              dinnerMap[dayOfWeek]![entry.key] =
                  (dinnerMap[dayOfWeek]![entry.key] ?? 0) + 1;
              break;
            }
          }
        }
      }

      // Converte os mapas em listas de PeakHourData para cada dia
      Map<String, List<PeakHourData>> newLunchWeekData = {
        "SEG.": [],
        "TER.": [],
        "QUA.": [],
        "QUI.": [],
        "SEX.": [],
      };
      Map<String, List<PeakHourData>> newDinnerWeekData = {
        "SEG.": [],
        "TER.": [],
        "QUA.": [],
        "QUI.": [],
        "SEX.": [],
      };

      for (int day = 1; day <= 5; day++) {
        String label = dayLabels[day - 1];
        DateTime base = startOfWeek.add(Duration(days: day - 1));
        lunchMap[day]!.forEach((intervalLabel, count) {
          DateTime intervalTime = DateFormat.Hm().parse(intervalLabel);
          intervalTime = DateTime(base.year, base.month, base.day, intervalTime.hour, intervalTime.minute);
          newLunchWeekData[label]!.add(PeakHourData(time: intervalTime, crowdLevel: count));
        });
        dinnerMap[day]!.forEach((intervalLabel, count) {
          DateTime intervalTime = DateFormat.Hm().parse(intervalLabel);
          intervalTime = DateTime(base.year, base.month, base.day, intervalTime.hour, intervalTime.minute);
          newDinnerWeekData[label]!.add(PeakHourData(time: intervalTime, crowdLevel: count));
        });
      }

      setState(() {
        lunchWeekData = newLunchWeekData;
        dinnerWeekData = newDinnerWeekData;
      });
    } catch (e) {
      print("Erro ao buscar check-ins: $e");
    }
  }

  /// Gera dados mock para a semana (segunda a sexta) para visualização rápida
  void generateMockWeekData() {
    Map<String, List<PeakHourData>> newLunchWeekData = {};
    Map<String, List<PeakHourData>> newDinnerWeekData = {};
    DateTime now = DateTime.now();

    for (int day = 1; day <= 5; day++) {
      String label = dayLabels[day - 1];
      DateTime base = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - day));
      // Almoço: intervalos de 1 hora (10:30, 11:30, 12:30, 13:30)
      List<PeakHourData> lunchList = [];
      for (int i = 0; i < 4; i++) {
        DateTime intervalTime =
        DateTime(base.year, base.month, base.day, 10, 30).add(Duration(hours: i));
        int crowd = 5 + (i * 3) + (day * 2);
        lunchList.add(PeakHourData(time: intervalTime, crowdLevel: crowd));
      }
      newLunchWeekData[label] = lunchList;

      // Jantar: intervalos de 1 hora (17:30, 18:30)
      List<PeakHourData> dinnerList = [];
      for (int i = 0; i < 2; i++) {
        DateTime intervalTime =
        DateTime(base.year, base.month, base.day, 17, 30).add(Duration(hours: i));
        int crowd = 3 + (i * 4) + (day * 2);
        dinnerList.add(PeakHourData(time: intervalTime, crowdLevel: crowd));
      }
      newDinnerWeekData[label] = dinnerList;
    }

    setState(() {
      lunchWeekData = newLunchWeekData;
      dinnerWeekData = newDinnerWeekData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: dayLabels.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Horários de pico", style: TextStyle(color: Colors.white)),
          backgroundColor: primaryOrange,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelPadding: EdgeInsets.symmetric(horizontal: 16),
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: dayLabels.map((day) => Tab(text: day)).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: dayLabels.map((dayLabel) {
            // Se os dados ainda não foram carregados, exibe um indicador
            if (lunchWeekData[dayLabel]!.isEmpty && dinnerWeekData[dayLabel]!.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDailyCharts(dayLabel),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Exibe os gráficos de almoço e jantar para um determinado dia
  Widget _buildDailyCharts(String dayLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gráfico de Almoço
        Text(
          "Almoço (10:30 - 14:30)",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryOrange,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 200,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelRotation: -45,
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 20,
              interval: 5,
              majorGridLines: MajorGridLines(width: 0),
            ),
            series: <ChartSeries>[
              ColumnSeries<PeakHourData, String>(
                dataSource: lunchWeekData[dayLabel]!,
                xValueMapper: (PeakHourData d, _) => DateFormat.Hm().format(d.time),
                yValueMapper: (PeakHourData d, _) => d.crowdLevel,
                pointColorMapper: (PeakHourData d, _) {
                  if (_isToday(dayLabel) && _isCurrentHour(d.time)) {
                    return backgroundColor;
                  }
                  return primaryOrange;
                },
              )
            ],
          ),
        ),
        SizedBox(height: 16),
        // Gráfico de Jantar
        Text(
          "Jantar (17:30 - 19:30)",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryOrange,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 200,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelRotation: -45,
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 20,
              interval: 5,
              majorGridLines: MajorGridLines(width: 0),
            ),
            series: <ChartSeries>[
              ColumnSeries<PeakHourData, String>(
                dataSource: dinnerWeekData[dayLabel]!,
                xValueMapper: (PeakHourData d, _) => DateFormat.Hm().format(d.time),
                yValueMapper: (PeakHourData d, _) => d.crowdLevel,
                pointColorMapper: (PeakHourData d, _) {
                  if (_isToday(dayLabel) && _isCurrentHour(d.time)) {
                    return backgroundColor;
                  }
                  return primaryOrange;
                },
              )
            ],
          ),
        ),
        // Indicador de swipe (somente para o dia atual)
        if (_isToday(dayLabel))
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_ios, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text("Arraste para ver outro dia", style: TextStyle(color: Colors.white)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Retorna true se o dia da aba corresponder ao dia de hoje (segunda a sexta)
  bool _isToday(String dayLabel) {
    final map = {
      "SEG.": 1,
      "TER.": 2,
      "QUA.": 3,
      "QUI.": 4,
      "SEX.": 5,
    };
    return map[dayLabel] == DateTime.now().weekday;
  }

  /// Retorna true se o horário do dado for igual ao horário atual
  bool _isCurrentHour(DateTime time) {
    DateTime now = DateTime.now();
    return (now.year == time.year &&
        now.month == time.month &&
        now.day == time.day &&
        now.hour == time.hour);
  }
}
