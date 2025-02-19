import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rutccc/models/cardapio.dart';
import 'package:rutccc/domain/services/cardapio_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

enum FilterOption { dia, semana, mes }

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

  // Configura os listeners do Firebase Messaging
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
    // Se o payload indicar que o cardápio foi atualizado, atualiza a lista
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

  Widget _buildFilterButton(String label, FilterOption option) {
    bool isSelected = _selectedFilter == option;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = option;
          });
          _applyFilter();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFE65100) : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCategory({
    required String title,
    required Map<String?, String?> options,
    required List<String> keys,
  }) {
    final List<Widget> items = keys.where((key) {
      return options[key] != null && options[key]!.isNotEmpty;
    }).map((key) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(iconMap[key] ?? Icons.restaurant, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                options[key]!,
                style: TextStyle(fontSize: 16, color: Colors.white),
                softWrap: true,
              ),
            ),
          ],
        ),
      );
    }).toList();

    if (items.isEmpty) return [];
    return [
      Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      SizedBox(height: 8),
      ...items,
      Divider(color: Colors.white, thickness: 1),
    ];
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
            Text(
              'Cardápio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCardapios,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Filtro com botões
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildFilterButton('Dia', FilterOption.dia),
                  SizedBox(width: 8),
                  _buildFilterButton('Semana', FilterOption.semana),
                  SizedBox(width: 8),
                  _buildFilterButton('Mês', FilterOption.mes),
                ],
              ),
            ),
            // Lista de Cardápios
            Expanded(
              child: _filteredCardapios.isEmpty
                  ? Center(
                child: Text('Nenhum cardápio disponível para o filtro selecionado.',
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
              )
                  : ListView.builder(
                itemCount: _filteredCardapios.length,
                itemBuilder: (context, index) {
                  final c = _filteredCardapios[index];
                  final options = {
                    'Opção 1': c.opcao1,
                    'Opção 2': c.opcao2,
                    'Opção Vegana': c.opcaoVegana,
                    'Opção Vegetariana': c.opcaoVegetariana,
                    'Salada 1': c.salada1,
                    'Salada 2': c.salada2,
                    'Guarnição': c.guarnicao,
                    'Acompanhamento 1': c.acompanhamento1,
                    'Acompanhamento 2': c.acompanhamento2,
                    'Suco': c.suco,
                    'Sobremesa': c.sobremesa,
                    'Café': c.cafe,
                    'Pão': c.pao,
                  };

                  return Card(
                    color: Color(0xFFE65100),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${c.refeicao} - Dia ${c.dia}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Divider(color: Colors.white, thickness: 1),
                          SizedBox(height: 8),
                          ..._buildCategory(
                            title: 'Pratos Principais',
                            options: options,
                            keys: ['Opção 1', 'Opção 2', 'Opção Vegana', 'Opção Vegetariana'],
                          ),
                          ..._buildCategory(
                            title: 'Saladas',
                            options: options,
                            keys: ['Salada 1', 'Salada 2'],
                          ),
                          ..._buildCategory(
                            title: 'Acompanhamentos',
                            options: options,
                            keys: ['Guarnição', 'Acompanhamento 1', 'Acompanhamento 2'],
                          ),
                          ..._buildCategory(
                            title: 'Bebidas e Sobremesas',
                            options: options,
                            keys: ['Suco', 'Sobremesa', 'Café', 'Pão'],
                          ),
                        ],
                      ),
                    ),
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
