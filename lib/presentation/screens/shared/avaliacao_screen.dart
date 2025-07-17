import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Certifique-se de que o caminho esteja correto

class AvaliacaoScreen extends StatefulWidget {
  const AvaliacaoScreen({super.key});

  @override
  _AvaliacaoScreenState createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen> {
  int? _avaliacao;
  final int _maxStars = 5;
  String? _refeicao;

  final List<bool> _selectedMeal = [false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Avaliação da Refeição", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFE65100),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Como você avaliaria a refeição?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _maxStars,
                      (index) => IconButton(
                    icon: Icon(
                      index < (_avaliacao ?? 0) ? Icons.star : Icons.star_border,
                      color: Color(0xFFE65100),
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _avaliacao = index + 1;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              Text(
                "Selecione a refeição:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
                selectedColor: Colors.white,
                fillColor: Color(0xFFE65100),
                isSelected: _selectedMeal,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selectedMeal.length; i++) {
                      _selectedMeal[i] = i == index;
                    }
                    _refeicao = index == 0 ? "Almoço" : "Jantar";
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Almoço", style: TextStyle(fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Jantar", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: (_avaliacao == null || _refeicao == null)
                    ? null
                    : () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Faça login para avaliar")),
                    );
                    return;
                  }
                  await _salvarAvaliacao(user.uid, _avaliacao!, _refeicao!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Avaliação registrada: $_avaliacao estrelas para $_refeicao")),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE65100),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: Text(
                  "Salvar Avaliação",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _salvarAvaliacao(String usuarioId, int avaliacao, String refeicao) async {
    try {
      final docId = "${usuarioId}_$refeicao";
      await FirebaseFirestore.instance.collection('avaliacoes').doc(docId).set({
        'usuario_id': usuarioId,
        'avaliacao': avaliacao,
        'refeicao': refeicao,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Avaliação salva com sucesso");
    } catch (e) {
      print("Erro ao salvar a avaliação: $e");
    }
  }
}
