class CrearBolicheDto {
  final String nombre;
  final String? direccion;

  CrearBolicheDto({required this.nombre, this.direccion});

  factory CrearBolicheDto.fromJson(Map<String, dynamic> json) {
    return CrearBolicheDto(
      nombre: json['nombre'],
      direccion: json['direccion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'direccion': direccion};
  }
}
