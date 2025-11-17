class ReservarMesaDto {
  final int bolicheId;
  final int mesaId;

  ReservarMesaDto({required this.bolicheId, required this.mesaId});

  factory ReservarMesaDto.fromJson(Map<String, dynamic> json) {
    return ReservarMesaDto(
      bolicheId: json['bolicheId'],
      mesaId: json['mesaId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'bolicheId': bolicheId, 'mesaId': mesaId};
  }
}
