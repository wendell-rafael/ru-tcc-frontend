import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> login(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    return await _getUserRole(userCredential.user!.uid);
  }

  Future<String> _getUserRole(String uid) async {
    DocumentSnapshot userDoc =
    await _firestore.collection("users").doc(uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      String role = (userDoc.data() as Map<String, dynamic>)["role"] ?? "user";
      return role;
    }
    return "user";
  }
}
