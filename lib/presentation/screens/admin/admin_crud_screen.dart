import 'package:flutter/material.dart';

import '../../domain/services/api_service.dart';

class AdminCrudScreen extends StatefulWidget {
  @override
  _AdminCrudScreenState createState() => _AdminCrudScreenState();
}

class _AdminCrudScreenState extends State<AdminCrudScreen> {
  String status = "Aguardando...";

  final apiService = ApiService();

  Future<void> testApi() async {
    try {
      final response = await apiService.get('/cardapios/');
      if (response.statusCode == 200) {
        setState(() {
          status = "Conectado com sucesso! 🎉";
        });
      } else {
        setState(() {
          status = "Erro: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        status = "Falha na conexão: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste de Conexão com API'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: testApi,
              icon: Icon(Icons.wifi, color: Colors.white),
              label: Text("Testar Conexão"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
