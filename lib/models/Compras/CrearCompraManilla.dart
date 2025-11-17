import 'package:doorpass/models/Compras/ItemManillaDto.dart';

class CrearCompraManillasDto {
  final int bolicheId;
  final List<ItemManillaDto> manillas;

  CrearCompraManillasDto({required this.bolicheId, required this.manillas});

  factory CrearCompraManillasDto.fromJson(Map<String, dynamic> json) {
    return CrearCompraManillasDto(
      bolicheId: json['bolicheId'],
      manillas:
          json['manillas'] != null
              ? (json['manillas'] as List)
                  .map((e) => ItemManillaDto.fromJson(e))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bolicheId': bolicheId,
      'manillas': manillas.map((e) => e.toJson()).toList(),
    };
  }
}
