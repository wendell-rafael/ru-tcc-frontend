import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de datas

class AlteracoesScreen extends StatefulWidget {
  const AlteracoesScreen({Key? key}) : super(key: key);

  @override
  _AlteracoesScreenState createState() => _AlteracoesScreenState();
}

class _AlteracoesScreenState extends State<AlteracoesScreen> {
  // Filtro de mês: 0 representa "Todos"
  int selectedMonth = 0;
  // Filtro de tipo: "Todos" por padrão
  String selectedType = "Todos";

  final List<Map<String, dynamic>> monthOptions = [
    {"name": "Todos", "value": 0},
    {"name": "Janeiro", "value": 1},
    {"name": "Fevereiro", "value": 2},
    {"name": "Março", "value": 3},
    {"name": "Abril", "value": 4},
    {"name": "Maio", "value": 5},
    {"name": "Junho", "value": 6},
    {"name": "Julho", "value": 7},
    {"name": "Agosto", "value": 8},
    {"name": "Setembro", "value": 9},
    {"name": "Outubro", "value": 10},
    {"name": "Novembro", "value": 11},
    {"name": "Dezembro", "value": 12},
  ];

  final List<Map<String, dynamic>> typeOptions = [
    {"name": "Todos", "value": "Todos"},
    {"name": "Opção 1", "value": "opcao1"},
    {"name": "Opção 2", "value": "opcao2"},
    {"name": "Opção Vegana", "value": "opcaoVegana"},
    {"name": "Opção Vegetariana", "value": "opcaoVegetariana"},
    {"name": "Salada 1", "value": "salada1"},
    {"name": "Salada 2", "value": "salada2"},
    {"name": "Guarnição", "value": "guarnicao"},
    {"name": "Acompanhamento 1", "value": "acompanhamento1"},
    {"name": "Acompanhamento 2", "value": "acompanhamento2"},
    {"name": "Suco", "value": "suco"},
    {"name": "Sobremesa", "value": "sobremesa"},
    {"name": "Café", "value": "cafe"},
    {"name": "Pão", "value": "pao"},
  ];

  final DateFormat dateFormatter = DateFormat("dd/MM/yyyy HH:mm");

  // Mapeamento para exibir os nomes com acentuação
  final Map<String, String> displayNames = {
    'opcao1': 'Opção 1',
    'opcao2': 'Opção 2',
    'opcaoVegana': 'Opção Vegana',
    'opcaoVegetariana': 'Opção Vegetariana',
    'salada1': 'Salada 1',
    'salada2': 'Salada 2',
    'guarnicao': 'Guarnição',
    'acompanhamento1': 'Acompanhamento 1',
    'acompanhamento2': 'Acompanhamento 2',
    'suco': 'Suco',
    'sobremesa': 'Sobremesa',
    'cafe': 'Café',
    'pao': 'Pão',
    'info': 'Informação',
  };

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = Color(0xFFE65100);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Alterações no Cardápio",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: orangeColor,
      ),
      body: Column(
        children: [
          // Filtros lado a lado usando Expanded para cada coluna
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Filtrar por Mês:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: orangeColor)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: orangeColor, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: orangeColor.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: DropdownButton<int>(
                          isExpanded: true,
                          underline: Container(),
                          value: selectedMonth,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: orangeColor),
                          items: monthOptions.map((option) {
                            return DropdownMenuItem<int>(
                              value: option['value'],
                              child: Text(
                                option['name'],
                                style: const TextStyle(color: orangeColor),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedMonth = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Filtrar por Tipo:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: orangeColor)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: orangeColor, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: orangeColor.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: Container(),
                          value: selectedType,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: orangeColor),
                          items: typeOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(
                                option['name'],
                                style: const TextStyle(color: orangeColor),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedType = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cardapioChanges')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Nenhuma alteração registrada."));
                }
                final docs = snapshot.data!.docs;
                // Filtra os documentos pelo mês
                List docsFilteredByMonth = selectedMonth == 0
                    ? docs
                    : docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final Timestamp ts = data['timestamp'];
                  final DateTime date = ts.toDate();
                  return date.month == selectedMonth;
                }).toList();
                // Filtra os documentos pelo tipo, se selecionado
                List filteredDocs = selectedType == "Todos"
                    ? docsFilteredByMonth
                    : docsFilteredByMonth.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final Map<String, dynamic> changes = data['changes'] ?? {};
                  return changes.containsKey(selectedType);
                }).toList();
                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("Nenhuma alteração para este filtro."));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var data = filteredDocs[index].data() as Map<String, dynamic>;
                    int dia = data['dia'] ?? 0;
                    String refeicao = data['refeicao'] ?? "";
                    Map<String, dynamic> changes = data['changes'] ?? {};
                    Timestamp timestamp = data['timestamp'];
                    DateTime date = timestamp.toDate();

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dia: $dia - $refeicao",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Data: ${dateFormatter.format(date)}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const Divider(),
                            ...changes.entries.map((entry) {
                              String displayKey = displayNames[entry.key] ?? entry.key;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        displayKey,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${entry.value['old'] ?? '-'}',
                                          style: TextStyle(
                                            color: Colors.red[800],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: Icon(Icons.arrow_forward, color: Colors.black45),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${entry.value['new'] ?? '-'}',
                                          style: TextStyle(
                                            color: Colors.green[800],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
