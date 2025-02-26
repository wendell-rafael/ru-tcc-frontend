import 'package:flutter/material.dart';
import 'package:rutccc/data/models/cardapio.dart';
import 'package:rutccc/domain/services/cardapio_service.dart';
import '../../widgets/CardapioListItem.dart';
import 'cardapio_form_screen.dart';

enum FilterOption { dia, semana, mes }

class CardapioListScreen extends StatefulWidget {
  @override
  _CardapioListScreenState createState() => _CardapioListScreenState();
}

class _CardapioListScreenState extends State<CardapioListScreen> {
  final CardapioService _cardapioService = CardapioService();
  List<Cardapio> cardapios = [];
  List<Cardapio> _allCardapios = [];
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
          SnackBar(content: Text('Erro ao buscar cardápios: $e')));
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
        filtered = _allCardapios
            .where((c) => c.dia >= startDay && c.dia <= endDay)
            .toList();
        break;
      case FilterOption.mes:
        filtered = _allCardapios;
        break;
    }
    setState(() {
      cardapios = filtered;
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

  Future<void> _deleteCardapio(int id) async {
    try {
      await _cardapioService.deleteCardapio(id);
      _fetchCardapios();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cardápio removido com sucesso')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover cardápio: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cardápios',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        backgroundColor: Color(0xFFE65100),
        toolbarHeight: 60,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtro
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

                  child: cardapios.isEmpty
                      ? Center(
                          child: Text(
                              'Nenhum cardápio encontrado para o filtro selecionado.',
                              textAlign: TextAlign.center))
                      : ListView.builder(
                          itemCount: cardapios.length,
                          itemBuilder: (context, index) {
                            final c = cardapios[index];
                            return CardapioListItem(
                              cardapio: c,
                              iconMap: iconMap,
                              onEdit: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CardapioFormScreen(cardapio: c),
                                  ),
                                );
                                _fetchCardapios();
                              },
                              onDelete: () => _deleteCardapio(c.id),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardapioFormScreen(),
            ),
          );
          _fetchCardapios();
        },
        child: Icon(Icons.add, color: Color(0xFFE65100)),
      ),
    );
  }
}
