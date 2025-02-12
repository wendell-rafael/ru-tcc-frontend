import 'package:flutter/material.dart';

class AdminCrudScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Cardápios'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Tela de gerenciamento de cardápios (CRUD)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE65100),
        onPressed: () {
          // Adicionar lógica para criar novo cardápio
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
// TODO Implement this library.