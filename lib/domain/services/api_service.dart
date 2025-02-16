import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000';

  // Obtém o token JWT do Firebase
  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // Requisição GET genérica
  Future<http.Response> get(String endpoint) async {
    final token = await _getToken();
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  // Requisição POST genérica
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
  }
}
