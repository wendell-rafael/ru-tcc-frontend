import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rutccc/presentation/screens/shared/avaliacao_screen.dart';

import '../user/heat_map_screen.dart';

class CheckInScreen extends StatefulWidget {
  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool isCheckedIn = false;

  // Função para fazer check-in
  Future<void> _checkIn() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Faça login para realizar o check-in")));
      return;
    }

    FirebaseFirestore.instance.collection('checkins').doc(user.uid).set({
      'usuario_id': user.uid,
      'status': 'presente',
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      setState(() {
        isCheckedIn = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Check-in realizado!")));
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao realizar check-in: $error")));
    });
  }

  // Função para fazer check-out e redirecionar para a tela de avaliação
  Future<void> _checkOut() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Faça login para realizar o check-out")));
      return;
    }

    FirebaseFirestore.instance.collection('checkins').doc(user.uid).update({
      'status': 'não presente',
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      setState(() {
        isCheckedIn = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Check-out realizado!")));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AvaliacaoScreen()),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao realizar check-out: $error")));
    });
  }

  // Função para navegar até o mapa de calor de check-ins
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
                isCheckedIn ? "Você está no RU!" : "Você ainda não fez check-in.",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                ),
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
              // Botão para acessar o mapa de calor
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
