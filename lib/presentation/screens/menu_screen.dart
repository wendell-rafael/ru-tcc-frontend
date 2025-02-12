import 'package:flutter/material.dart';
import 'mock_menu.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _filter = 'Hoje'; // Filtro padrão
  List<Map<String, dynamic>> filteredMenu = [];
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
    'Acompanhamento 3': Icons.local_dining,
    'Suco': Icons.local_drink,
    'Sobremesa': Icons.icecream,
    'Café': Icons.coffee,
    'Pão': Icons.bakery_dining,
  };

  @override
  void initState() {
    super.initState();
    _applyFilter(); // Aplica o filtro padrão
  }

  void _applyFilter() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));

    setState(() {
      if (_filter == 'Hoje') {
        filteredMenu = mockMenu.where((menu) {
          return menu['date'] == now.day;
        }).toList();
      } else if (_filter == 'Semana') {
        filteredMenu = mockMenu.where((menu) {
          final date = menu['date'];
          return date >= weekStart.day && date <= weekEnd.day;
        }).toList();
      } else if (_filter == 'Mês') {
        filteredMenu = mockMenu; // Exibe todos os itens do mock
      }
    });
  }

  void _showLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.grey[100],
          title: Text(
            'Legenda dos Ícones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Fechar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(IconData icon, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Color(0xFFE65100), size: 28),
        SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE65100),
        toolbarHeight: 80.0, // Aumenta a altura da AppBar
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cardápio',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Texto na cor branca
              ),
            ),
            DropdownButton<String>(
              value: _filter,
              dropdownColor: Color(0xFFE65100),
              icon: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(Icons.filter_list, color: Colors.white),
              ),
              underline: SizedBox(),
              items: ['Hoje', 'Semana', 'Mês']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Colors.white, // Texto do Dropdown na cor branca
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _filter = newValue;
                    _applyFilter();
                  });
                }
              },
            ),
          ],
        ),
      ),
      body: filteredMenu.isEmpty
          ? Center(
              child: Text(
                'Nenhum cardápio disponível.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.builder(
              itemCount: filteredMenu.length,
              itemBuilder: (context, index) {
                final menu = filteredMenu[index];
                return Card(
                  color: Color(0xFFE65100), // Fundo laranja no card
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${menu['meal']} - Dia ${menu['date']}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Texto branco
                          ),
                        ),
                        Divider(color: Colors.white, thickness: 1), // Linha divisória branca
                        SizedBox(height: 8),
                        ..._buildCategory(
                          'Pratos Principais',
                          menu['options'],
                          ['Opção 1', 'Opção 2', 'Opção Vegana', 'Opção Vegetariana'],
                        ),
                        Divider(color: Colors.white, thickness: 1),
                        ..._buildCategory(
                          'Saladas',
                          menu['options'],
                          ['Salada 1', 'Salada 2'],
                        ),
                        Divider(color: Colors.white, thickness: 1),
                        ..._buildCategory(
                          'Acompanhamentos',
                          menu['options'],
                          ['Guarnição', 'Acompanhamento 1', 'Acompanhamento 2'],
                        ),
                        Divider(color: Colors.white, thickness: 1),
                        ..._buildCategory(
                          'Bebidas e Sobremesas',
                          menu['options'],
                          ['Suco', 'Sobremesa', 'Café', 'Pão'],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE65100),
        onPressed: () => _showLegend(context),
        tooltip: 'Legenda dos Ícones',
        child: Icon(Icons.help_outline, color: Colors.white),
      ),
    );
  }

  List<Widget> _buildCategory(String title, Map<String, String> options, List<String> keys) {
    return [
      Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Título da categoria em branco
        ),
      ),
      SizedBox(height: 8),
      ...keys.map((key) {
        if (options[key] != null && options[key]!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  iconMap[key] ?? Icons.restaurant,
                  color: Colors.white, // Ícone branco
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    options[key]!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Texto branco
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      }),
    ];
  }

}
