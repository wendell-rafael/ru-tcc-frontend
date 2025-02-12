import 'package:flutter/material.dart';
import 'admin_crud_screen.dart';
import 'admin_upload_csv_screen.dart';
import 'admin_settings_screen.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  static final List<Widget> _widgetOptions = <Widget>[
    AdminCrudScreen(),       // Gerenciamento de cardápios (CRUD)
    AdminUploadCsvScreen(),  // Upload de CSV
    AdminSettingsScreen(),   // Configurações e logout
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 250),
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
        physics: BouncingScrollPhysics(), // Scroll mais fluido
        children: _widgetOptions,
        onPageChanged: _onPageChanged,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Cardápios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload CSV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFE65100),
        onTap: _onItemTapped,
      ),
    );
  }
}
