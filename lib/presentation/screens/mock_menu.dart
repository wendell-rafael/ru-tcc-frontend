final List<Map<String, dynamic>> mockMenu = List.generate(60, (index) {
  final day = (index ~/ 2) + 1; // Cada dois índices corresponde a um dia (almoço e jantar)
  final mealType = index % 2 == 0 ? 'Almoço' : 'Jantar';
  return {
    'meal': mealType,
    'date': day,
    'options': {
      'Opção 1': mealType == 'Almoço'
          ? 'Prato principal do almoço dia $day'
          : 'Prato principal do jantar dia $day',
      'Opção 2': mealType == 'Almoço'
          ? 'Prato secundário do almoço dia $day'
          : 'Prato secundário do jantar dia $day',
      'Opção Vegana': mealType == 'Almoço'
          ? 'Prato vegano do almoço dia $day'
          : 'Prato vegano do jantar dia $day',
      'Opção Vegetariana': mealType == 'Almoço'
          ? 'Prato vegetariano do almoço dia $day'
          : 'Prato vegetariano do jantar dia $day',
      'Salada 1': 'Salada 1 do dia $day',
      'Salada 2': 'Salada 2 do dia $day',
      'Guarnição': 'Guarnição do dia $day',
      'Acompanhamento 1': 'Acompanhamento 1 do dia $day',
      'Acompanhamento 2': 'Acompanhamento 2 do dia $day',
      'Suco': 'Suco do dia $day',
      'Sobremesa': 'Sobremesa do dia $day',
    },
  };
});
