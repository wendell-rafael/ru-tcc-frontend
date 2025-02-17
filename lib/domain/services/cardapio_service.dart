import 'dart:convert';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rutccc/models/cardapio.dart';

class CardapioService {
  final String baseUrl = 'http://192.168.0.5:8000';

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  List<Cardapio> _decodeCardapios(String responseBody) {
    final decoded = convert.utf8.decode(responseBody.runes.toList());
    List<dynamic> data = jsonDecode(decoded);
    return data.map((e) => Cardapio.fromJson(e)).toList();
  }

  // 📌 GET: Listar todos os cardápios
  Future<List<Cardapio>> getCardapios() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/cardapios/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );
    if (response.statusCode == 200) {
      return _decodeCardapios(response.body);
    } else {
      throw Exception('Erro ao buscar cardápios: ${response.statusCode}');
    }
  }

  // 📌 GET: Obter Cardápio por ID
  Future<Cardapio> getCardapioById(int id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/cardapios/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );
    if (response.statusCode == 200) {
      final decoded = convert.utf8.decode(response.body.runes.toList());
      return Cardapio.fromJson(jsonDecode(decoded));
    } else {
      throw Exception('Erro ao buscar o cardápio');
    }
  }

  // 📌 POST: Criar novo cardápio
  Future<void> createCardapio(Cardapio cardapio) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/cardapios/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode(cardapio.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar cardápio');
    }
  }

  Future<void> updateCardapio(int id, Cardapio cardapio) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/cardapios/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode(cardapio.toJson()), // ✅ Agora inclui o ID no corpo
    );

    if (response.statusCode != 200) {
      print('Erro no PUT: ${response.statusCode}');
      print('Resposta: ${response.body}');
      throw Exception('Erro ao atualizar cardápio: ${response.body}');
    }
  }


  // 📌 PATCH: Atualizar parcialmente
  Future<void> patchCardapio(int id, Map<String, dynamic> updates) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/cardapios/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar parcialmente');
    }
  }

  // 📌 DELETE: Remover cardápio
  Future<void> deleteCardapio(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/cardapios/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao remover cardápio');
    }
  }
}
