import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rutccc/data/models/cardapio.dart';
import 'package:rutccc/domain/services/cardapio_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Importa o enum compartilhado
import 'package:rutccc/core/enums.dart';
import '../../widgets/cardapio_card.dart';
import '../../widgets/filter_bar.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final CardapioService _cardapioService = CardapioService();
  List<Cardapio> _allCardapios = [];
  List<Cardapio> _filteredCardapios = [];
  bool isLoading = true;
  FilterOption _selectedFilter = FilterOption.dia;

  final Map<String, IconData> iconMap = {
    'Opção 1': Icons.set_meal,
    'Opção 2': Icons.set_meal,
    'Opção Vegana': Icons.eco,
    'Opção Vegetariana': Icons.spa,
    'Salada 1': Icons.grass,
    'Salada 2': Icons.grass,
    'Guarnição': Icons.rice_bowl,
    'Acompanhamento 1': Icons.local_dining,
    'Acompanhamento 2': Icons.local_dining,
    'Suco': Icons.local_drink,
    'Sobremesa': Icons.icecream,
    'Café': Icons.coffee,
    'Pão': Icons.bakery_dining,
  };

  @override
  void initState() {
    super.initState();
    _fetchCardapios();
    _configureFCM();
  }

  void _configureFCM() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'cardapio_updated') {
      _fetchCardapios();
    }
  }

  Future<void> _fetchCardapios() async {
    try {
      List<Cardapio> fetched = await _cardapioService.getCardapios();
      setState(() {
        _allCardapios = fetched;
      });
      _applyFilter();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar cardápios: $e')),
      );
    }
  }

  void _applyFilter() {
    DateTime now = DateTime.now();
    List<Cardapio> filtered;
    switch (_selectedFilter) {
      case FilterOption.dia:
        filtered = _allCardapios.where((c) => c.dia == now.day).toList();
        break;
      case FilterOption.semana:
        int startDay = now.day;
        int endDay = now.day + 6;
        filtered = _allCardapios.where((c) => c.dia >= startDay && c.dia <= endDay).toList();
        break;
      case FilterOption.mes:
        filtered = _allCardapios;
        break;
    }
    setState(() {
      _filteredCardapios = filtered;
      isLoading = false;
    });
  }

  void _showLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.grey[100],
          title: Text(
            'Legenda dos Ícones',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(Icons.set_meal, 'Prato Principal'),
              _buildLegendItem(Icons.eco, 'Opção Vegana'),
              _buildLegendItem(Icons.spa, 'Opção Vegetariana'),
              _buildLegendItem(Icons.grass, 'Salada'),
              _buildLegendItem(Icons.rice_bowl, 'Guarnição'),
              _buildLegendItem(Icons.local_dining, 'Acompanhamento'),
              _buildLegendItem(Icons.local_drink, 'Suco'),
              _buildLegendItem(Icons.icecream, 'Sobremesa'),
              _buildLegendItem(Icons.coffee, 'Café'),
              _buildLegendItem(Icons.bakery_dining, 'Pão'),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Fechar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFE65100), size: 28),
        SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE65100),
        toolbarHeight: 80.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cardápio', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCardapios,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Utiliza o widget FilterBar para os botões de filtro
            FilterBar(
              selectedFilter: _selectedFilter,
              onFilterChanged: (newFilter) {
                setState(() {
                  _selectedFilter = newFilter;
                });
                _applyFilter();
              },
            ),
            Expanded(
              child: _filteredCardapios.isEmpty
                  ? Center(
                child: Text(
                  'Nenhum cardápio disponível para o filtro selecionado.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredCardapios.length,
                itemBuilder: (context, index) {
                  return CardapioCard(
                    cardapio: _filteredCardapios[index],
                    iconMap: iconMap,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE65100),
        onPressed: () => _showLegend(context),
        tooltip: 'Legenda dos Ícones',
        child: Icon(Icons.help_outline, color: Colors.white),
      ),
    );
  }
}
