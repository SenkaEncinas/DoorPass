import 'package:doorpass/models/Entities/Boliche.dart';

class ManillaTipo {
  final int id;
  final String nombre;
  final double precio;
  final int stock;
  final int bolicheId;
  final Boliche boliche;

  ManillaTipo({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.bolicheId,
    required this.boliche,
  });

  factory ManillaTipo.fromJson(Map<String, dynamic> json) {
    return ManillaTipo(
      id: json['id'],
      nombre: json['nombre'],
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'],
      bolicheId: json['bolicheId'],
      boliche: Boliche.fromJson(json['boliche']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'stock': stock,
      'bolicheId': bolicheId,
      'boliche': boliche.toJson(),
    };
  }
}
