import 'package:flutter/material.dart';
import 'package:rutccc/data/models/cardapio.dart';

class CardapioListItem extends StatelessWidget {
  final Cardapio cardapio;
  final Map<String, IconData> iconMap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardapioListItem({
    Key? key,
    required this.cardapio,
    required this.iconMap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  List<Widget> _buildCategory({
    required String title,
    required Map<String?, String?> options,
    required List<String> keys,
  }) {
    final List<Widget> items = keys.where((key) => options[key] != null && options[key]!.isNotEmpty)
        .map((key) {
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

  @override
  Widget build(BuildContext context) {
    final options = {
      'Opção 1': cardapio.opcao1,
      'Opção 2': cardapio.opcao2,
      'Opção Vegana': cardapio.opcaoVegana,
      'Opção Vegetariana': cardapio.opcaoVegetariana,
      'Salada 1': cardapio.salada1,
      'Salada 2': cardapio.salada2,
      'Guarnição': cardapio.guarnicao,
      'Acompanhamento 1': cardapio.acompanhamento1,
      'Acompanhamento 2': cardapio.acompanhamento2,
      'Suco': cardapio.suco,
      'Sobremesa': cardapio.sobremesa,
      'Café': cardapio.cafe,
      'Pão': cardapio.pao,
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
              '${cardapio.refeicao} - Dia ${cardapio.dia}',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirmar Remoção'),
                        content: Text('Deseja remover este cardápio?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            child: Text('Remover', style: TextStyle(color: Colors.red)),
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
  }
}
