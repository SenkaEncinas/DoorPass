class ItemComboCompradoDto {
  final String nombreCombo;
  final int cantidad;
  final double precioPagado;

  ItemComboCompradoDto({
    required this.nombreCombo,
    required this.cantidad,
    required this.precioPagado,
  });

  factory ItemComboCompradoDto.fromJson(Map<String, dynamic> json) {
    return ItemComboCompradoDto(
      nombreCombo: json['nombreCombo'],
      cantidad: json['cantidad'],
      precioPagado: (json['precioPagado'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreCombo': nombreCombo,
      'cantidad': cantidad,
      'precioPagado': precioPagado,
    };
  }
}
