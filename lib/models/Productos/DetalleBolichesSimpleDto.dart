class DetalleBolicheSimpleDto {
  final int id;
  final String nombre;
  final String direccion;

  DetalleBolicheSimpleDto({
    required this.id,
    required this.nombre,
    required this.direccion,
  });

  factory DetalleBolicheSimpleDto.fromJson(Map<String, dynamic> json) {
    return DetalleBolicheSimpleDto(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'direccion': direccion};
  }
}
