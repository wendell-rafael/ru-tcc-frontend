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

  String _generateGravatarUrl(String email) {
    final bytes = utf8.encode(email.trim().toLowerCase());
    final digest = md5.convert(bytes);
    return 'https://www.gravatar.com/avatar/$digest?s=200&d=mp';
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

      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await userCredential.user!.updateDisplayName(name.trim());

      // Define se o usuário é admin ou user
      String role = (email == "admin@ru.com") ? "admin" : "user";

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'dietaryRestriction': dietaryRestriction,
        'photoUrl': _generateGravatarUrl(email),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseError(e);
    } finally {
      setLoading(false);
    }
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    if (e.code == 'email-already-in-use') return 'Email já está em uso.';
    if (e.code == 'invalid-email') return 'Formato de email inválido.';
    if (e.code == 'weak-password') return 'Senha fraca. Escolha uma mais forte.';
    return 'Erro ao cadastrar usuário.';
  }
}
