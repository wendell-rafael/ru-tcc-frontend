import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/user.dart';

class UserService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'valor_default';

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // 📌 GET - Listar Usuários
  Future<List<UserNormal>> getUsers() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => UserNormal.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar usuários: ${response.statusCode}');
    }
  }

  // 📌 GET - Obter Usuário por ID
  Future<UserNormal> getUserById(String id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return UserNormal.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Usuário não encontrado');
    }
  }

  // 📌 POST - Criar Usuário
  Future<void> createUser(UserNormal user) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar usuário');
    }
  }

  // 📌 PUT - Atualizar Usuário
  Future<void> updateUser(String id, UserNormal user) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar usuário');
    }
  }

  // 📌 DELETE - Remover Usuário
  Future<void> deleteUser(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao remover usuário');
    }
  }
}
