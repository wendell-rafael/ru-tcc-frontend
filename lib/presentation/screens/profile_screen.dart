import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rutccc/presentation/screens/login_screen.dart';
import 'package:intl/intl.dart';
import '../../domain/services/favorito_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int favoritesCount = 0;
  DateTime? lastCheckin;
  final FavoriteService favoriteService = FavoriteService();

  @override
  void initState() {
    super.initState();
    _fetchFavoritesCount();
    _fetchLastCheckin();
  }

  // Busca a quantidade de favoritos via FavoriteService
  Future<void> _fetchFavoritesCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final favorites = await favoriteService.getFavorites(user.uid);
        setState(() {
          favoritesCount = favorites.length;
        });
      } catch (e) {
        print("Erro ao carregar favoritos via API: $e");
      }
    }
  }

  // Busca o último check-in do usuário via Firestore
  Future<void> _fetchLastCheckin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('checkins')
          .doc(user.uid)
          .get();
      if (docSnapshot.exists) {
        final ts = docSnapshot.get('timestamp');
        if (ts != null && ts is Timestamp) {
          setState(() {
            lastCheckin = ts.toDate();
          });
        }
      }
    }
  }

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
    final User? user = FirebaseAuth.instance.currentUser;
    final gravatarUrl = user != null ? _getGravatarUrl(user.email!) : null;
    // Se não houver gravatar, usa o ícone account_circle
    final displayPhotoUrl = gravatarUrl;
    final userName = user?.displayName ?? 'Usuário';
    final userEmail = user?.email ?? 'Email não disponível';
    final userUid = user?.uid ?? 'UID não disponível';
    final lastCheckinStr = lastCheckin != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(lastCheckin!)
        : "Sem check-in";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE65100),
        toolbarHeight: 80.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Perfil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cabeçalho com informações do usuário
            Container(
              width: double.infinity,
              color: Color(0xFFE65100),
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: displayPhotoUrl != null
                        ? NetworkImage(displayPhotoUrl)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: displayPhotoUrl == null
                        ? Icon(Icons.account_circle,
                            size: 60, color: Colors.white)
                        : null,
                  ),
                  SizedBox(height: 16),
                  Text(
                    userName,
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
            SizedBox(height: 12),
            // Card com informações adicionais da conta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.email, color: Color(0xFFE65100)),
                        title: Text("Email",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(userEmail),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.favorite, color: Color(0xFFE65100)),
                        title: Text("Total de Favoritos",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("$favoritesCount"),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.check, color: Color(0xFFE65100)),
                        title: Text("Último Check-in",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(lastCheckinStr),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
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
      ),
    );
  }
}
