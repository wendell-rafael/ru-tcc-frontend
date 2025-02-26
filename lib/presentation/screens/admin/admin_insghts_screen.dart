import 'package:flutter/material.dart';
import 'insight_screens/student_distribution.dart';
import 'insight_screens/meal_changes.dart';
import 'insight_screens/attendance_trends.dart';
import 'insight_screens/meal_attendance.dart';
import 'insight_screens/feedbacks.dart';
import 'insight_screens/menu_changes.dart';

class AdminDashboardInsightsScreen extends StatelessWidget {
  final Color orangeColor = const Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Insights do RU"), backgroundColor: orangeColor),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildButton(context, "📊 Distribuição de Alunos", StudentDistributionScreen()),
          _buildButton(context, "🍽️ Alterações por Refeição", MealChangesScreen()),
          _buildButton(context, "📆 Tendência de Check-ins", AttendanceTrendsScreen()),
          _buildButton(context, "🏆 Comparação Almoço x Jantar", MealAttendanceScreen()),
          _buildButton(context, "⭐ Feedbacks de Alunos", FeedbacksScreen()),
          _buildButton(context, "🔄 Mudanças no Cardápio", MenuChangesScreen()),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: orangeColor, padding: EdgeInsets.all(16)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
        child: Text(title, style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
