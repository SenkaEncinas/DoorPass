import 'ItemComboDto.dart';

class CrearCompraCombosDto {
  final int bolicheId;
  final List<ItemComboDto> combos;

  CrearCompraCombosDto({required this.bolicheId, this.combos = const []});

  factory CrearCompraCombosDto.fromJson(Map<String, dynamic> json) {
    return CrearCompraCombosDto(
      bolicheId: json['bolicheId'],
      combos:
          json['combos'] != null
              ? List<ItemComboDto>.from(
                json['combos'].map((x) => ItemComboDto.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bolicheId': bolicheId,
      'combos': combos.map((x) => x.toJson()).toList(),
    };
  }
}
