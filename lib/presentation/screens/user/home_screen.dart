import 'package:flutter/material.dart';
import 'package:rutccc/presentation/screens/profile_screen.dart';
import 'favorite_screen.dart';
import 'menu_screen.dart';
import 'checkin_screen.dart'; // Adicionando a tela de check-in

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  static final List<Widget> _widgetOptions = <Widget>[
    MenuScreen(), // Tela de Menu
    FavoritesScreen(), // Tela
    CheckInScreen(), // Nova Tela de Check-in// de Favoritos
    ProfileScreen(), // Tela de Perfil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _widgetOptions,
        onPageChanged: _onPageChanged,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle), // Ícone do check-in
            label: 'Check-in', // Rótulo do check-in
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFE65100),
        onTap: _onItemTapped,
        type: BottomNavigationBarType
            .fixed, // Fixando o tipo para garantir que todos os ícones apareçam
      ),
    );
  }
}
