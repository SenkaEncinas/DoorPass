import 'Boliche.dart';

class Combo {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String? imagenUrl;
  final int bolicheId;
  final Boliche? boliche;

  Combo({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.imagenUrl,
    required this.bolicheId,
    this.boliche,
  });

  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      imagenUrl: json['imagenUrl'],
      bolicheId: json['bolicheId'],
      boliche:
          json['boliche'] != null ? Boliche.fromJson(json['boliche']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'bolicheId': bolicheId,
      'boliche': boliche?.toJson(),
    };
  }
}
