// ignore_for_file: unused_import

import 'package:rutccc/data/models/cardapio.dart';
import 'package:rutccc/data/models/favorito.dart';
import 'dart:convert';

import 'api_service.dart';

final apiService = ApiService();

// 📌 GET: Buscar cardápios
Future<List<Cardapio>> getCardapios() async {
  final response = await apiService.get('/cardapios/');
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Cardapio.fromJson(e)).toList();
  } else {
    throw Exception('Erro ao buscar cardápios');
  }
}

// 📌 POST: Adicionar favorito
Future<void> addFavorito(String usuarioId, String prato) async {
  final response = await apiService.post('/favoritos/', {
    'usuario_id': usuarioId,
    'prato': prato,
  });
  if (response.statusCode != 200) {
    throw Exception('Erro ao adicionar favorito');
  }
}
