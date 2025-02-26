import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../domain/services/favorito_service.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/profile_info_card.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int favoritesCount = 0;
  DateTime? lastCheckin;
  String? lastRefeicao;
  final FavoriteService favoriteService = FavoriteService();

  @override
  void initState() {
    super.initState();
    _fetchFavoritesCount();
    _fetchLastCheckin();
  }

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

  Future<void> _fetchLastCheckin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('checkins')
          .where('usuario_id', isEqualTo: user.uid)
          .orderBy('timestamp_checkin', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first.data() as Map<String, dynamic>;

        if (doc.containsKey('timestamp_checkin')) {
          Timestamp ts = doc['timestamp_checkin'];
          String? refeicao = doc['refeicao'] ?? "Refeição não registrada";

          print("✅ Último check-in encontrado: ${ts.toDate()} - $refeicao");

          if (mounted) {
            setState(() {
              lastCheckin = ts.toDate();
              lastRefeicao = refeicao;
            });
          }
        } else {
          print("⚠️ Documento encontrado, mas sem timestamp_checkin!");
        }
      } else {
        print("⚠️ Nenhum check-in encontrado para o usuário!");
      }
    } catch (e) {
      print("Erro ao buscar o último check-in: $e");
    }
  }


  String _getGravatarUrl(String email) {
    final emailLower = email.trim().toLowerCase();
    final hash = md5.convert(utf8.encode(emailLower)).toString();
    return 'https://www.gravatar.com/avatar/$hash?s=200&d=404';
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
    final displayPhotoUrl = gravatarUrl;
    final userName = user?.displayName ?? 'Usuário';
    final userEmail = user?.email ?? 'Email não disponível';
    final lastCheckinStr = lastCheckin != null
        ? "${DateFormat('dd/MM/yyyy HH:mm').format(lastCheckin!)} ($lastRefeicao)"
        : "Sem check-in";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE65100),
        toolbarHeight: 80.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Perfil', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(userName: userName, photoUrl: displayPhotoUrl, email: userEmail),
            SizedBox(height: 12),
            ProfileInfoCard(email: userEmail, favoritesCount: favoritesCount, lastCheckin: lastCheckinStr),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Sair da Conta', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
