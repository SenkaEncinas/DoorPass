import 'package:doorpass/models/Entities/ManillaTipo.dart';
import 'package:doorpass/models/Entities/Mesa.dart';

class Boliche {
  final int id;
  final String nombre;
  final String? direccion;
  final List<ManillaTipo> manillaTipos;
  final List<Mesa> mesas;

  Boliche({
    required this.id,
    required this.nombre,
    this.direccion,
    this.manillaTipos = const [],
    this.mesas = const [],
  });

  factory Boliche.fromJson(Map<String, dynamic> json) {
    return Boliche(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      manillaTipos:
          json['manillaTipos'] != null
              ? List<ManillaTipo>.from(
                json['manillaTipos'].map((x) => ManillaTipo.fromJson(x)),
              )
              : [],
      mesas:
          json['mesas'] != null
              ? List<Mesa>.from(json['mesas'].map((x) => Mesa.fromJson(x)))
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'manillaTipos': manillaTipos.map((x) => x.toJson()).toList(),
      'mesas': mesas.map((x) => x.toJson()).toList(),
    };
  }
}
