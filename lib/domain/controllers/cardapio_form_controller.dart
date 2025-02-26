import 'package:rutccc/data/models/cardapio.dart';

class CardapioFormController {
  Map<String, Map<String, dynamic>> calcularDiferencas(Cardapio oldCardapio, Cardapio newCardapio) {
    final diffs = <String, Map<String, dynamic>>{};

    // Função para normalizar valores: transforma valores nulos, vazios ou com espaços apenas em null
    dynamic normalize(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        final trimmed = value.trim();
        return trimmed.isEmpty ? null : trimmed;
      }
      return value;
    }

    // Mapeamento dos campos com seus getters
    final fields = <String, dynamic Function(Cardapio)>{
      'opcao1': (c) => c.opcao1,
      'opcao2': (c) => c.opcao2,
      'opcaoVegana': (c) => c.opcaoVegana,
      'opcaoVegetariana': (c) => c.opcaoVegetariana,
      'salada1': (c) => c.salada1,
      'salada2': (c) => c.salada2,
      'guarnicao': (c) => c.guarnicao,
      'acompanhamento1': (c) => c.acompanhamento1,
      'acompanhamento2': (c) => c.acompanhamento2,
      'suco': (c) => c.suco,
      'sobremesa': (c) => c.sobremesa,
      'cafe': (c) => c.cafe,
      'pao': (c) => c.pao,
    };

    fields.forEach((field, getter) {
      final oldValue = normalize(getter(oldCardapio));
      final newValue = normalize(getter(newCardapio));
      if (oldValue != newValue) {
        diffs[field] = {'old': oldValue, 'new': newValue};
      }
    });

    return diffs;
  }
}
