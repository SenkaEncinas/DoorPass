class ItemCompradoDto {
  final String nombreManilla;
  final int cantidad;
  final double precioPagado;

  ItemCompradoDto({
    required this.nombreManilla,
    required this.cantidad,
    required this.precioPagado,
  });

  factory ItemCompradoDto.fromJson(Map<String, dynamic> json) {
    return ItemCompradoDto(
      nombreManilla: json['nombreManilla'],
      cantidad: json['cantidad'],
      precioPagado: (json['precioPagado'] as num).toDouble(),
    );
  }

  get precio => null;

  Map<String, dynamic> toJson() {
    return {
      'nombreManilla': nombreManilla,
      'cantidad': cantidad,
      'precioPagado': precioPagado,
    };
  }
}
