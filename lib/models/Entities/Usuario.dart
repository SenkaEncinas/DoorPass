import 'package:doorpass/models/Entities/Compra.dart';

class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String rol; // "Admin", "Staff", "Usuario"
  final List<Compra> compras;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.compras = const [],
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      rol: json['rol'],
      compras:
          json['compras'] != null
              ? (json['compras'] as List)
                  .map((e) => Compra.fromJson(e))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'compras': compras.map((c) => c.toJson()).toList(),
    };
  }
}
