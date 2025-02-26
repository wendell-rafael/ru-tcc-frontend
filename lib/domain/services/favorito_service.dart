import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FavoriteService {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? 'http://192.168.0.5:8000'}/favoritos';

  Future<List<dynamic>> getFavorites(String usuarioId) async {
    try {
      final url = Uri.parse('$baseUrl/$usuarioId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedResponse);
      } else {
        throw Exception('Erro ao carregar favoritos');
      }
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
      rethrow;
    }
  }

  Future<void> addFavorite(String usuarioId, String prato) async {
    try {
      final url = Uri.parse(
        '$baseUrl/?usuario_id=$usuarioId&prato=${Uri.encodeComponent(prato)}',
      );
      final response = await http.post(url);
      if (response.statusCode != 200) {
        throw Exception('Erro ao adicionar favorito');
      }
    } catch (e) {
      print('Erro ao adicionar favorito: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(int id) async {
    try {
      final url = '$baseUrl/$id';
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Erro ao remover favorito');
      }
    } catch (e) {
      print('Erro ao remover favorito: $e');
      rethrow;
    }
  }
}
