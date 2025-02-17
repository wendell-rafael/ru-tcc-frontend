class Cardapio {
  final int id;
  final String refeicao;
  final int dia;
  final String? opcao1;
  final String? opcao2;
  final String? opcaoVegana;
  final String? opcaoVegetariana;
  final String? salada1;
  final String? salada2;
  final String? guarnicao;
  final String? acompanhamento1;
  final String? acompanhamento2;
  final String? suco;
  final String? sobremesa;
  final String? cafe;
  final String? pao;

  Cardapio({
    required this.id,
    required this.refeicao,
    required this.dia,
    this.opcao1,
    this.opcao2,
    this.opcaoVegana,
    this.opcaoVegetariana,
    this.salada1,
    this.salada2,
    this.guarnicao,
    this.acompanhamento1,
    this.acompanhamento2,
    this.suco,
    this.sobremesa,
    this.cafe,
    this.pao,
  });

  factory Cardapio.fromJson(Map<String, dynamic> json) {
    return Cardapio(
      id: json['id'],
      refeicao: json['refeicao'],
      dia: json['dia'],
      opcao1: json['opcao1'],
      opcao2: json['opcao2'],
      opcaoVegana: json['opcao_vegana'],
      opcaoVegetariana: json['opcao_vegetariana'],
      salada1: json['salada1'],
      salada2: json['salada2'],
      guarnicao: json['guarnicao'],
      acompanhamento1: json['acompanhamento1'],
      acompanhamento2: json['acompanhamento2'],
      suco: json['suco'],
      sobremesa: json['sobremesa'],
      cafe: json['cafe'],
      pao: json['pao'],
    );
  }

  Map<String, dynamic> toJson() {
    String? clean(String? value) => (value == null || value.trim().isEmpty) ? null : value;

    return {
      'id': id,
      'dia': dia,
      'refeicao': clean(refeicao),
      'opcao1': clean(opcao1),
      'opcao2': clean(opcao2),
      'opcao_vegana': clean(opcaoVegana),
      'opcao_vegetariana': clean(opcaoVegetariana),
      'salada1': clean(salada1),
      'salada2': clean(salada2),
      'guarnicao': clean(guarnicao),
      'acompanhamento1': clean(acompanhamento1),
      'acompanhamento2': clean(acompanhamento2),
      'suco': clean(suco),
      'sobremesa': clean(sobremesa),
      'cafe': clean(cafe),
      'pao': clean(pao),
    };
  }


}
