import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class RegisterController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Gera a URL do Gravatar com base no email
  String _generateGravatarUrl(String email) {
    final bytes = utf8.encode(email.trim().toLowerCase());
    final digest = md5.convert(bytes);
    return 'https://www.gravatar.com/avatar/$digest?s=200&d=mp';
  }

  // Define se o usuário será admin baseado no email
  bool _isAdmin(String email) {
    List<String> adminEmails = ["admin@ru.com", "superuser@ru.com"];
    return adminEmails.contains(email.trim().toLowerCase());
  }

  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String dietaryRestriction,
  }) async {
    if (password != confirmPassword) {
      return 'As senhas não coincidem.';
    }

    try {
      setLoading(true);

      // Criando usuário no Firebase Auth
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Atualiza o nome do usuário no perfil
      await userCredential.user!.updateDisplayName(name.trim());

      // Define a role do usuário (se for um email admin, define como admin)
      String role = _isAdmin(email) ? "admin" : "user";

      // Salva os dados do usuário no Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role, // Define o usuário como admin ou user
        'dietaryRestriction': dietaryRestriction,
        'photoUrl': _generateGravatarUrl(email),
      });

      return null; // Cadastro bem-sucedido

    } on FirebaseAuthException catch (e) {
      return _handleFirebaseError(e);
    } finally {
      setLoading(false);
    }
  }

  // Método para buscar a role do usuário
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection("users").doc(uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      return (userDoc.data() as Map<String, dynamic>)["role"];
    }
    return null;
  }

  // Tratamento de erros do Firebase
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email já está em uso.';
      case 'invalid-email':
        return 'Formato de email inválido.';
      case 'weak-password':
        return 'Senha fraca. Escolha uma mais forte.';
      default:
        return 'Erro ao cadastrar usuário.';
    }
  }
}
