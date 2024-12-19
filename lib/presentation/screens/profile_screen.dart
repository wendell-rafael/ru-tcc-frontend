import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rutccc/presentation/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  String _getGravatarUrl(String email) {
    final emailLower = email.trim().toLowerCase();
    final hash = md5.convert(utf8.encode(emailLower)).toString();
    return 'https://www.gravatar.com/avatar/$hash?s=200&d=identicon';
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user =
        FirebaseAuth.instance.currentUser; // Pega o usuário autenticado
    final gravatarUrl = user != null ? _getGravatarUrl(user.email!) : null;
    final userName = user?.displayName ?? 'Usuário'; // Nome do usuário

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE65100),
        toolbarHeight: 80.0, // Altura maior para a AppBar
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Perfil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24, // Tamanho do texto maior
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                // Ação ao clicar no botão de editar
                print("Editar perfil clicado");
              },
              icon: Icon(Icons.edit, color: Colors.white), // Ícone de editar
              tooltip: 'Editar Perfil',
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cabeçalho com informações do usuário
          Container(
            width: double.infinity, // Ocupa toda a largura da tela
            color: Color(0xFFE65100),
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      gravatarUrl != null ? NetworkImage(gravatarUrl) : null,
                  backgroundColor: Colors.grey[300],
                  child: gravatarUrl == null
                      ? Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                SizedBox(height: 16),
                Text(
                  userName, // Exibe o nome do usuário
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Bem-vindo(a) ao RU na Palma da Mão",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Aqui você pode gerenciar sua conta.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ),
          // Botão de sair
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Sair da Conta',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
