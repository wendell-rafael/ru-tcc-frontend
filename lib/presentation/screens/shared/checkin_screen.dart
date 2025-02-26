import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../user/heat_map_screen.dart';
import '../shared/avaliacao_screen.dart';

class CheckInScreen extends StatefulWidget {
  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool isCheckedIn = false;
  String? lastCheckinId;
  String? refeicaoInferida;
  String? checkinTime;
  String? checkoutTime;

  @override
  void initState() {
    super.initState();
    _loadCheckInStatus();
  }

  Future<void> _loadCheckInStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DateTime today = DateTime.now();
      String formattedDate = "${today.year}-${today.month}-${today.day}";

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('checkins')
          .where('usuario_id', isEqualTo: user.uid)
          .where('data', isEqualTo: formattedDate)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var sortedDocs = snapshot.docs.toList()
          ..sort((a, b) {
            Timestamp tA = a['timestamp_checkin'];
            Timestamp tB = b['timestamp_checkin'];
            return tB.compareTo(tA); // 🔥 Ordenamos por check-in mais recente
          });

        var doc = sortedDocs.first; // Pegamos o último check-in do dia

        setState(() {
          lastCheckinId = doc.id;
          isCheckedIn = doc['checkout'] ==
              null; // Se checkout for null, usuário ainda está no RU
          refeicaoInferida = doc['refeicao'];
          checkinTime = doc['checkin'];
          checkoutTime = doc['checkout'];
        });
      }
    }
  }

  // 🔥 Função que formata corretamente a hora e minuto
  String _formatTime(int hour, int minute) {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  // 🔥 Função que infere a refeição com base no horário
  String _inferirRefeicao(DateTime horario) {
    TimeOfDay horarioAtual =
        TimeOfDay(hour: horario.hour, minute: horario.minute);

    TimeOfDay almocoInicio = TimeOfDay(hour: 10, minute: 30);
    TimeOfDay almocoFim = TimeOfDay(hour: 14, minute: 30);
    TimeOfDay jantarInicio = TimeOfDay(hour: 17, minute: 30);
    TimeOfDay jantarFim = TimeOfDay(hour: 19, minute: 30);

    bool isBetween(TimeOfDay start, TimeOfDay end, TimeOfDay current) {
      int currentMinutes = current.hour * 60 + current.minute;
      int startMinutes = start.hour * 60 + start.minute;
      int endMinutes = end.hour * 60 + end.minute;
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    }

    if (isBetween(almocoInicio, almocoFim, horarioAtual)) return "Almoço";
    if (isBetween(jantarInicio, jantarFim, horarioAtual)) return "Jantar";
    return "Fora do horário"; // Caso raro
  }

  Future<void> _checkIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Faça login para realizar o check-in")),
      );
      return;
    }

    DateTime now = DateTime.now();
    String formattedDate = "${now.year}-${now.month}-${now.day}";
    String formattedTime =
        _formatTime(now.hour, now.minute); // 🔥 Formata corretamente o horário

    // 🔥 Inferir refeição automaticamente
    String refeicao = _inferirRefeicao(now);
    if (refeicao == "Fora do horário") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "O check-in só pode ser feito nos horários das refeições.")),
      );
      return;
    }

    DocumentReference checkinRef =
        await FirebaseFirestore.instance.collection('checkins').add({
      'usuario_id': user.uid,
      'refeicao': refeicao,
      'data': formattedDate,
      'checkin': formattedTime,
      'checkout': null,
      'timestamp_checkin': FieldValue.serverTimestamp(),
    });

    setState(() {
      isCheckedIn = true;
      lastCheckinId = checkinRef.id;
      refeicaoInferida = refeicao;
      checkinTime = formattedTime;
      checkoutTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text("Check-in registrado às $formattedTime para $refeicao")),
    );
  }

  Future<void> _checkOut() async {
    if (lastCheckinId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Faça login para realizar o check-out")),
      );
      return;
    }

    DateTime now = DateTime.now();
    String formattedTime =
        _formatTime(now.hour, now.minute); // 🔥 Formata corretamente o horário

    await FirebaseFirestore.instance
        .collection('checkins')
        .doc(lastCheckinId)
        .update({
      'checkout': formattedTime,
      'timestamp_checkout': FieldValue.serverTimestamp(),
    });

    setState(() {
      isCheckedIn = false;
      lastCheckinId = null;
      checkoutTime = formattedTime;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Check-out registrado às $formattedTime")),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AvaliacaoScreen()),
    );
  }

  void _openHeatMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HeatMapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE65100),
        toolbarHeight: 80.0,
        title: Text(
          "Check-in no RU",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isCheckedIn
                    ? "Você está no RU para o $refeicaoInferida!"
                    : "Você ainda não fez check-in.",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100)),
              ),
              SizedBox(height: 20),
              Icon(
                Icons.restaurant,
                size: 100,
                color: Color(0xFFE65100),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: isCheckedIn ? null : _checkIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE65100),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Fazer Check-in",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isCheckedIn ? _checkOut : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Finalizar Check-out",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _openHeatMap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Ver Mapa de Calor",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
