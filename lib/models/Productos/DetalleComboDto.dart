class DetalleComboDto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;

  DetalleComboDto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
  });

  factory DetalleComboDto.fromJson(Map<String, dynamic> json) {
    return DetalleComboDto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      imagenUrl: json['imagenUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
    };
  }
}
