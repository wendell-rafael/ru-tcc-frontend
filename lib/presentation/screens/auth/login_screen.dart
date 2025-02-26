import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rutccc/presentation/screens/auth/register_screen.dart';
import 'package:rutccc/presentation/screens/admin/admin_screen.dart';
import 'package:rutccc/presentation/screens/user/home_screen.dart';
import 'package:rutccc/presentation/widgets/custom_text_field.dart';
import 'package:rutccc/presentation/widgets/custom_password_field.dart';
import 'package:rutccc/presentation/widgets/custom_button.dart';
import '../../../domain/controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _focusPassword = FocusNode();

  bool _isLoading = false;

  final LoginController _loginController = LoginController();

  Future<void> _loginWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Utiliza o LoginController para efetuar o login e obter o role
      String userRole = await _loginController.login(
        _emailController.text,
        _passwordController.text,
      );

      // Direciona o usuário para a tela correta
      if (userRole == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login realizado com sucesso!')),
      );
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      String errorMessage = 'Erro ao fazer login';
      if (e.code == 'user-not-found') {
        errorMessage = 'Usuário não encontrado. Verifique o email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta. Tente novamente.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Formato de email inválido.';
      } else if (e.code == 'invalid-credential') {
        errorMessage =
        'Credenciais inválidas. Verifique seus dados e tente novamente.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Fecha o teclado ao tocar fora
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 150,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Bem-vindo(a)!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Faça login para continuar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 32),
                    CustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      nextFocus: _focusPassword,
                    ),
                    CustomPasswordField(
                      label: 'Senha',
                      controller: _passwordController,
                      focusNode: _focusPassword,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 24),
                    _isLoading
                        ? CircularProgressIndicator()
                        : CustomButton(
                      label: 'Entrar',
                      onPressed: _loginWithEmailAndPassword,
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Não tem uma conta? Cadastre-se",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
