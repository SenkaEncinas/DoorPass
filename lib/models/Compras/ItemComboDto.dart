class ItemComboDto {
  final int comboId;
  final int cantidad;

  ItemComboDto({required this.comboId, required this.cantidad});

  factory ItemComboDto.fromJson(Map<String, dynamic> json) {
    return ItemComboDto(comboId: json['comboId'], cantidad: json['cantidad']);
  }

  Map<String, dynamic> toJson() {
    return {'comboId': comboId, 'cantidad': cantidad};
  }
}
