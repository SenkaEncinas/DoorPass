class DetalleManillaTipoDto {
  final int id;
  final String nombre;
  final double precio;
  final int stock;
  final int bolicheId;

  DetalleManillaTipoDto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.bolicheId,
  });

  factory DetalleManillaTipoDto.fromJson(Map<String, dynamic> json) {
    return DetalleManillaTipoDto(
      id: json['id'],
      nombre: json['nombre'],
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'],
      bolicheId: json['bolicheId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'stock': stock,
      'bolicheId': bolicheId,
    };
  }
}
