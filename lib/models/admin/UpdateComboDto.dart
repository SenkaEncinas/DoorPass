class UpdateComboDto {
  String nombre;
  String? descripcion;
  double precio;
  String? imagenUrl;

  UpdateComboDto({
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.imagenUrl,
  });

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
    };
  }

  // Crear instancia desde JSON (opcional, si recibes datos del backend)
  factory UpdateComboDto.fromJson(Map<String, dynamic> json) {
    return UpdateComboDto(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      imagenUrl: json['imagenUrl'],
    );
  }
}
