import 'package:flutter/material.dart';
import 'package:rutccc/models/cardapio.dart';
import '../../domain/services/cardapio_service.dart';
import 'cardapio_form_screen.dart';

class CardapioListScreen extends StatefulWidget {
  @override
  _CardapioListScreenState createState() => _CardapioListScreenState();
}

class _CardapioListScreenState extends State<CardapioListScreen> {
  final CardapioService _cardapioService = CardapioService();
  List<Cardapio> cardapios = [];
  bool isLoading = true;

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
        cardapios = fetched;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar cardápios: $e')),
      );
    }
  }

  Future<void> _deleteCardapio(int id) async {
    try {
      await _cardapioService.deleteCardapio(id);
      _fetchCardapios();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cardápio removido com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover cardápio: $e')),
      );
    }
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
            Icon(iconMap[key] ?? Icons.restaurant,
                color: Colors.white, size: 22),
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
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      SizedBox(height: 8),
      ...items,
      Divider(color: Colors.white, thickness: 1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cardapios.isEmpty
              ? Center(child: Text('Nenhum cardápio encontrado'))
              : ListView.builder(
                  itemCount: cardapios.length,
                  itemBuilder: (context, index) {
                    final c = cardapios[index];
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
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Divider(color: Colors.white, thickness: 1),
                            ..._buildCategory(
                              title: 'Pratos Principais',
                              options: options,
                              keys: [
                                'Opção 1',
                                'Opção 2',
                                'Opção Vegana',
                                'Opção Vegetariana'
                              ],
                            ),
                            ..._buildCategory(
                              title: 'Saladas',
                              options: options,
                              keys: ['Salada 1', 'Salada 2'],
                            ),
                            ..._buildCategory(
                              title: 'Acompanhamentos',
                              options: options,
                              keys: [
                                'Guarnição',
                                'Acompanhamento 1',
                                'Acompanhamento 2'
                              ],
                            ),
                            ..._buildCategory(
                              title: 'Bebidas e Sobremesas',
                              options: options,
                              keys: ['Suco', 'Sobremesa', 'Café', 'Pão'],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CardapioFormScreen(cardapio: c),
                                      ),
                                    );
                                    _fetchCardapios();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Confirmar Remoção'),
                                        content: Text(
                                            'Deseja remover este cardápio?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _deleteCardapio(c.id);
                                            },
                                            child: Text('Remover',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardapioFormScreen(),
            ),
          );
          _fetchCardapios(); // ✅ Atualiza automaticamente após criação
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
