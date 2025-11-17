import 'package:doorpass/models/Compras/ItemManillaDto.dart';

class CrearCompraDto {
  final String bolicheId;
  final List<ItemManillaDto> manillas;
  final String? mesaId;

  CrearCompraDto({
    required this.bolicheId,
    this.manillas = const [],
    this.mesaId,
  });

  factory CrearCompraDto.fromJson(Map<String, dynamic> json) {
    return CrearCompraDto(
      bolicheId: json['bolicheId'],
      manillas:
          json['manillas'] != null
              ? List<ItemManillaDto>.from(
                json['manillas'].map((x) => ItemManillaDto.fromJson(x)),
              )
              : [],
      mesaId: json['mesaId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bolicheId': bolicheId,
      'manillas': manillas.map((x) => x.toJson()).toList(),
      'mesaId': mesaId,
    };
  }
}
