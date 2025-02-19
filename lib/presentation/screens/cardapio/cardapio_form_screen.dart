import 'package:flutter/material.dart';
import 'package:rutccc/data/models/cardapio.dart';
import '../../domain/services/cardapio_service.dart';

class CardapioFormScreen extends StatefulWidget {
  final Cardapio? cardapio;

  const CardapioFormScreen({Key? key, this.cardapio}) : super(key: key);

  @override
  _CardapioFormScreenState createState() => _CardapioFormScreenState();
}

class _CardapioFormScreenState extends State<CardapioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CardapioService _cardapioService = CardapioService();

  // Campos
  late int dia;
  late String refeicao;
  String? opcao1, opcao2, opcaoVegana, opcaoVegetariana;
  String? salada1, salada2, guarnicao;
  String? acompanhamento1, acompanhamento2, suco;
  String? sobremesa, cafe, pao;

  @override
  void initState() {
    super.initState();
    // Preenche com valores existentes ou padrões
    dia = widget.cardapio?.dia ?? DateTime.now().day;
    refeicao = widget.cardapio?.refeicao ?? 'Almoço';
    opcao1 = widget.cardapio?.opcao1;
    opcao2 = widget.cardapio?.opcao2;
    opcaoVegana = widget.cardapio?.opcaoVegana;
    opcaoVegetariana = widget.cardapio?.opcaoVegetariana;
    salada1 = widget.cardapio?.salada1;
    salada2 = widget.cardapio?.salada2;
    guarnicao = widget.cardapio?.guarnicao;
    acompanhamento1 = widget.cardapio?.acompanhamento1;
    acompanhamento2 = widget.cardapio?.acompanhamento2;
    suco = widget.cardapio?.suco;
    sobremesa = widget.cardapio?.sobremesa;
    cafe = widget.cardapio?.cafe;
    pao = widget.cardapio?.pao;
  }

  // Função para calcular as diferenças entre o cardápio antigo e o novo
  Map<String, Map<String, dynamic>> _calcularDiferencas(Cardapio oldCardapio, Cardapio newCardapio) {
    final Map<String, Map<String, dynamic>> diffs = {};
    if (oldCardapio.opcao1 != newCardapio.opcao1) {
      diffs['opcao1'] = {'old': oldCardapio.opcao1, 'new': newCardapio.opcao1};
    }
    if (oldCardapio.opcao2 != newCardapio.opcao2) {
      diffs['opcao2'] = {'old': oldCardapio.opcao2, 'new': newCardapio.opcao2};
    }
    if (oldCardapio.opcaoVegana != newCardapio.opcaoVegana) {
      diffs['opcaoVegana'] = {'old': oldCardapio.opcaoVegana, 'new': newCardapio.opcaoVegana};
    }
    if (oldCardapio.opcaoVegetariana != newCardapio.opcaoVegetariana) {
      diffs['opcaoVegetariana'] = {'old': oldCardapio.opcaoVegetariana, 'new': newCardapio.opcaoVegetariana};
    }
    if (oldCardapio.salada1 != newCardapio.salada1) {
      diffs['salada1'] = {'old': oldCardapio.salada1, 'new': newCardapio.salada1};
    }
    if (oldCardapio.salada2 != newCardapio.salada2) {
      diffs['salada2'] = {'old': oldCardapio.salada2, 'new': newCardapio.salada2};
    }
    if (oldCardapio.guarnicao != newCardapio.guarnicao) {
      diffs['guarnicao'] = {'old': oldCardapio.guarnicao, 'new': newCardapio.guarnicao};
    }
    if (oldCardapio.acompanhamento1 != newCardapio.acompanhamento1) {
      diffs['acompanhamento1'] = {'old': oldCardapio.acompanhamento1, 'new': newCardapio.acompanhamento1};
    }
    if (oldCardapio.acompanhamento2 != newCardapio.acompanhamento2) {
      diffs['acompanhamento2'] = {'old': oldCardapio.acompanhamento2, 'new': newCardapio.acompanhamento2};
    }
    if (oldCardapio.suco != newCardapio.suco) {
      diffs['suco'] = {'old': oldCardapio.suco, 'new': newCardapio.suco};
    }
    if (oldCardapio.sobremesa != newCardapio.sobremesa) {
      diffs['sobremesa'] = {'old': oldCardapio.sobremesa, 'new': newCardapio.sobremesa};
    }
    if (oldCardapio.cafe != newCardapio.cafe) {
      diffs['cafe'] = {'old': oldCardapio.cafe, 'new': newCardapio.cafe};
    }
    if (oldCardapio.pao != newCardapio.pao) {
      diffs['pao'] = {'old': oldCardapio.pao, 'new': newCardapio.pao};
    }
    return diffs;
  }

  Future<void> _saveCardapio() async {
    if (_formKey.currentState!.validate()) {
      String? clean(String? value) =>
          (value == null || value.trim().isEmpty) ? null : value;

      final newCardapio = Cardapio(
        id: widget.cardapio?.id ?? 0,
        dia: dia,
        refeicao: refeicao,
        opcao1: clean(opcao1),
        opcao2: clean(opcao2),
        opcaoVegana: clean(opcaoVegana),
        opcaoVegetariana: clean(opcaoVegetariana),
        salada1: clean(salada1),
        salada2: clean(salada2),
        guarnicao: clean(guarnicao),
        acompanhamento1: clean(acompanhamento1),
        acompanhamento2: clean(acompanhamento2),
        suco: clean(suco),
        sobremesa: clean(sobremesa),
        cafe: clean(cafe),
        pao: clean(pao),
      );

      try {
        if (widget.cardapio == null) {
          await _cardapioService.createCardapio(newCardapio);
          // Opcional: registrar a criação como alteração
          await _cardapioService.registrarAlteracao(
            dia: newCardapio.dia,
            refeicao: newCardapio.refeicao,
            changes: {
              'info': {'old': null, 'new': 'Cardápio criado'}
            },
          );
        } else {
          await _cardapioService.updateCardapio(widget.cardapio!.id, newCardapio);
          // Calcula as diferenças e registra se houver alterações
          final diff = _calcularDiferencas(widget.cardapio!, newCardapio);
          if (diff.isNotEmpty) {
            await _cardapioService.registrarAlteracao(
              dia: newCardapio.dia,
              refeicao: newCardapio.refeicao,
              changes: diff,
            );
          }
        }

        Navigator.pop(context, true); // Atualiza lista ao retornar
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required String? initialValue,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Digite $label...',
          prefixIcon: icon != null ? Icon(icon, color: Colors.orange) : null,
          labelStyle:
          TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        style: TextStyle(fontSize: 16),
        validator: isRequired
            ? (value) =>
        value == null || value.isEmpty ? 'Preencha $label' : null
            : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownRefeicao() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<String>(
        value: refeicao.isNotEmpty ? refeicao : 'Almoço',
        decoration: InputDecoration(
          labelText: 'Refeição',
          hintText: 'Selecione a refeição...',
          prefixIcon: Icon(Icons.restaurant_menu, color: Colors.orange),
          labelStyle:
          TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        items: <String>['Almoço', 'Jantar'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            refeicao = value ?? 'Almoço';
          });
        },
        validator: (value) =>
        value == null || value.isEmpty ? 'Selecione uma refeição' : null,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cardapio == null ? 'Novo Cardápio' : 'Editar Cardápio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveCardapio,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Informações Gerais'),
                _buildTextField(
                  label: 'Dia',
                  initialValue: dia.toString(),
                  onChanged: (value) =>
                  dia = int.tryParse(value ?? '1') ?? 1,
                  isRequired: true,
                  icon: Icons.calendar_today,
                ),
                _buildDropdownRefeicao(),
                Divider(thickness: 2, color: Colors.grey),
                _buildSectionTitle('Pratos Principais'),
                _buildTextField(
                    label: 'Opção 1',
                    initialValue: opcao1,
                    onChanged: (v) => opcao1 = v,
                    icon: Icons.set_meal),
                _buildTextField(
                    label: 'Opção 2',
                    initialValue: opcao2,
                    onChanged: (v) => opcao2 = v,
                    icon: Icons.dinner_dining),
                _buildTextField(
                    label: 'Opção Vegana',
                    initialValue: opcaoVegana,
                    onChanged: (v) => opcaoVegana = v,
                    icon: Icons.eco),
                _buildTextField(
                    label: 'Opção Vegetariana',
                    initialValue: opcaoVegetariana,
                    onChanged: (v) => opcaoVegetariana = v,
                    icon: Icons.spa),
                Divider(thickness: 2, color: Colors.grey),
                _buildSectionTitle('Saladas e Acompanhamentos'),
                _buildTextField(
                    label: 'Salada 1',
                    initialValue: salada1,
                    onChanged: (v) => salada1 = v,
                    icon: Icons.grass),
                _buildTextField(
                    label: 'Salada 2',
                    initialValue: salada2,
                    onChanged: (v) => salada2 = v,
                    icon: Icons.grass),
                _buildTextField(
                    label: 'Guarnição',
                    initialValue: guarnicao,
                    onChanged: (v) => guarnicao = v,
                    icon: Icons.rice_bowl),
                _buildTextField(
                    label: 'Acompanhamento 1',
                    initialValue: acompanhamento1,
                    onChanged: (v) => acompanhamento1 = v,
                    icon: Icons.fastfood),
                _buildTextField(
                    label: 'Acompanhamento 2',
                    initialValue: acompanhamento2,
                    onChanged: (v) => acompanhamento2 = v,
                    icon: Icons.fastfood),
                Divider(thickness: 2, color: Colors.grey),
                _buildSectionTitle('Extras'),
                _buildTextField(
                    label: 'Suco',
                    initialValue: suco,
                    onChanged: (v) => suco = v,
                    icon: Icons.local_drink),
                _buildTextField(
                    label: 'Sobremesa',
                    initialValue: sobremesa,
                    onChanged: (v) => sobremesa = v,
                    icon: Icons.icecream),
                _buildTextField(
                    label: 'Café',
                    initialValue: cafe,
                    onChanged: (v) => cafe = v,
                    icon: Icons.coffee),
                _buildTextField(
                    label: 'Pão',
                    initialValue: pao,
                    onChanged: (v) => pao = v,
                    icon: Icons.bakery_dining),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saveCardapio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: Size(double.infinity, 60),
                  ),
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
