class UpdateBolicheDto {
  final String nombre;
  final String? direccion;
  final String? descripcion;
  final String? imagenUrl;

  UpdateBolicheDto({
    required this.nombre,
    this.direccion,
    this.descripcion,
    this.imagenUrl,
  });

  factory UpdateBolicheDto.fromJson(Map<String, dynamic> json) {
    return UpdateBolicheDto(
      nombre: json['nombre'],
      direccion: json['direccion'],
      descripcion: json['descripcion'],
      imagenUrl: json['imagenUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
    };
  }
}
