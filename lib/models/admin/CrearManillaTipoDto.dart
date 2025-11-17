class CrearManillaTipoDto {
  final String nombre;
  final double precio;
  final int stock;

  CrearManillaTipoDto({
    required this.nombre,
    required this.precio,
    required this.stock,
  });

  factory CrearManillaTipoDto.fromJson(Map<String, dynamic> json) {
    return CrearManillaTipoDto(
      nombre: json['nombre'],
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'precio': precio, 'stock': stock};
  }
}
