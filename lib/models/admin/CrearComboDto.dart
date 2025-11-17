class CrearComboDto {
  final String nombre;
  final String? descripcion;
  final double precio;
  final String? imagenUrl;

  CrearComboDto({
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.imagenUrl,
  });

  factory CrearComboDto.fromJson(Map<String, dynamic> json) {
    return CrearComboDto(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      imagenUrl: json['imagenUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
    };
  }
}
