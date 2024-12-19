import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rutccc/presentation/screens/login_screen.dart';
import 'package:rutccc/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: Colors.black, // Cor primária como preto
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          // AppBar com fundo preto
          iconTheme: IconThemeData(color: Colors.white),
          // Ícones na AppBar em branco
          titleTextStyle: TextStyle(
            color: Colors.white, // Texto da AppBar em branco
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.black, // Preto para interações como seletores
          secondary: Colors.black, // Preto para elementos complementares
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
          // Cor do cursor ao digitar texto
          selectionColor: Colors.black.withOpacity(0.4),
          // Cor da seleção de texto
          selectionHandleColor: Colors.black, // Cor das âncoras de seleção
        ),
      ),
      title: '', // Remova o título global
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return HomeScreen(); // Usuário autenticado
          }
          return LoginScreen(); // Usuário não autenticado
        },
      ),
    );
  }
}
