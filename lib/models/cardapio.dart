class Cardapio {
  final int id;
  final int dia;
  final String refeicao;
  final String? opcao1;
  final String? opcao2;

  Cardapio({
    required this.id,
    required this.dia,
    required this.refeicao,
    this.opcao1,
    this.opcao2,
  });

  factory Cardapio.fromJson(Map<String, dynamic> json) {
    return Cardapio(
      id: json['id'],
      dia: json['dia'],
      refeicao: json['refeicao'],
      opcao1: json['opcao1'],
      opcao2: json['opcao2'],
    );
  }
}
