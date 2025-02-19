import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../../domain/services/favorito_service.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _favorites = [];  // Lista de favoritos obtida do backend

  final FavoriteService _favoriteService = FavoriteService(); // Instancia do serviço
  String? usuarioId;  // ID do usuário

  @override
  void initState() {
    super.initState();
    _getUsuarioId();  // Obtém o usuário ID do Firebase
  }

  // Função para pegar o UID do Firebase
  Future<void> _getUsuarioId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          usuarioId = user.uid;  // Define o UID do usuário
        });
        _loadFavorites();  // Carrega os favoritos após obter o UID
      }
    } catch (e) {
      print('Erro ao obter o usuarioId: $e');
    }
  }

  // Busca os favoritos do usuário no backend
  Future<void> _loadFavorites() async {
    if (usuarioId == null) return;

    try {
      List<dynamic> favorites = await _favoriteService.getFavorites(usuarioId!);
      setState(() {
        _favorites = favorites;
      });
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
    }
  }

  // Adiciona um favorito chamando o backend
  Future<void> _addFavorite() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, digite o nome de um item.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (usuarioId != null) {
      try {
        await _favoriteService.addFavorite(usuarioId!, text);
        _controller.clear();
        _loadFavorites();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Favorito adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar favorito.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Remove um favorito chamando o backend
  Future<void> _removeFavorite(int id) async {
    try {
      await _favoriteService.removeFavorite(id);
      _loadFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Favorito removido com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover favorito.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE65100),
        toolbarHeight: 80.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Favoritos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'O que você gostaria de comer?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Digite o nome do item...',
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Color(0xFFE65100),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addFavorite,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE65100),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  child: Text('Adicionar', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Seus Favoritos:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
            ),
            SizedBox(height: 8),
            Expanded(
              child: _favorites.isEmpty
                  ? Center(child: Text('Nenhum favorito adicionado.', style: TextStyle(fontSize: 18, color: Colors.black54)))
                  : ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final favorite = _favorites[index];
                  return Card(
                    color: Color(0xFFE65100),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(
                        favorite['prato'],
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () => _removeFavorite(favorite['id']),
                        tooltip: 'Remover',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
