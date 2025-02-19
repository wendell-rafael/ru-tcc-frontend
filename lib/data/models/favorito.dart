class Favorito {
  final int id;
  final String usuarioId;
  final String prato;

  Favorito({
    required this.id,
    required this.usuarioId,
    required this.prato,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      id: json['id'],
      usuarioId: json['usuario_id'],
      prato: json['prato'],
    );
  }
}
