import 'ManillaTipo.dart';
import 'Mesa.dart';
import 'Combo.dart';

class Boliche {
  final int id;
  final String nombre;
  final String? direccion;
  final String? descripcion;
  final String? imagenUrl;
  final List<ManillaTipo> manillaTipos;
  final List<Mesa> mesas;
  final List<Combo> combos;

  Boliche({
    required this.id,
    required this.nombre,
    this.direccion,
    this.descripcion,
    this.imagenUrl,
    this.manillaTipos = const [],
    this.mesas = const [],
    this.combos = const [],
  });

  factory Boliche.fromJson(Map<String, dynamic> json) {
    return Boliche(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      descripcion: json['descripcion'],
      imagenUrl: json['imagenUrl'],
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
      combos:
          json['combos'] != null
              ? List<Combo>.from(json['combos'].map((x) => Combo.fromJson(x)))
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'manillaTipos': manillaTipos.map((x) => x.toJson()).toList(),
      'mesas': mesas.map((x) => x.toJson()).toList(),
      'combos': combos.map((x) => x.toJson()).toList(),
    };
  }
}
