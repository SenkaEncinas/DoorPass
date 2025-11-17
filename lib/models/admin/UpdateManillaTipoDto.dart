class UpdateManillaTipoDto {
  final String nombre;
  final double precio;
  final int stock;

  UpdateManillaTipoDto({
    required this.nombre,
    required this.precio,
    required this.stock,
  });

  factory UpdateManillaTipoDto.fromJson(Map<String, dynamic> json) {
    return UpdateManillaTipoDto(
      nombre: json['nombre'],
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'precio': precio, 'stock': stock};
  }
}
