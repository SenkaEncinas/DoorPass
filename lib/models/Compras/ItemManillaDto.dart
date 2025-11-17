class ItemManillaDto {
  final int manillaTipoId;
  final int cantidad;

  ItemManillaDto({required this.manillaTipoId, required this.cantidad});

  factory ItemManillaDto.fromJson(Map<String, dynamic> json) {
    return ItemManillaDto(
      manillaTipoId: json['manillaTipoId'],
      cantidad: json['cantidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'manillaTipoId': manillaTipoId, 'cantidad': cantidad};
  }
}
