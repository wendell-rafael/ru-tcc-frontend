import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FavoriteService {
  final String baseUrl = 'http://192.168.0.5:8000/favoritos'; // URL base do seu backend

  // Função para obter todos os favoritos de um usuário
  Future<List<dynamic>> getFavorites(String usuarioId) async {
    try {
      final url = Uri.parse('$baseUrl/$usuarioId');
      final response = await http.get(url);

      // Garante que a resposta seja decodificada corretamente em UTF-8
      if (response.statusCode == 200) {
        // Usa utf8.decode para garantir a codificação correta
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

  // Função para adicionar um favorito
  Future<void> addFavorite(String usuarioId, String prato) async {
    try {
      final url = Uri.parse('$baseUrl/?usuario_id=$usuarioId&prato=${Uri.encodeComponent(prato)}');
      final response = await http.post(url);
      if (response.statusCode != 200) {
        throw Exception('Erro ao adicionar favorito');
      }
    } catch (e) {
      print('Erro ao adicionar favorito: $e');
      rethrow;
    }
  }

  // Função para remover um favorito
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
