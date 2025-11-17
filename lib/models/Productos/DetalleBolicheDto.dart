import 'DetalleManillaTipoDto.dart';
import 'DetalleMesaDto.dart';
import 'DetalleComboDto.dart';

class DetalleBolicheDto {
  final int id;
  final String nombre;
  final String? direccion;
  final String? descripcion;
  final String? imagenUrl;

  final List<DetalleManillaTipoDto> manillas;
  final List<DetalleMesaDto> mesas;
  final List<DetalleComboDto> combos;

  DetalleBolicheDto({
    required this.id,
    required this.nombre,
    this.direccion,
    this.descripcion,
    this.imagenUrl,
    this.manillas = const [],
    this.mesas = const [],
    this.combos = const [],
  });

  factory DetalleBolicheDto.fromJson(Map<String, dynamic> json) {
    return DetalleBolicheDto(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      descripcion: json['descripcion'],
      imagenUrl: json['imagenUrl'],
      manillas:
          json['manillas'] != null
              ? List<DetalleManillaTipoDto>.from(
                json['manillas'].map((x) => DetalleManillaTipoDto.fromJson(x)),
              )
              : [],
      mesas:
          json['mesas'] != null
              ? List<DetalleMesaDto>.from(
                json['mesas'].map((x) => DetalleMesaDto.fromJson(x)),
              )
              : [],
      combos:
          json['combos'] != null
              ? List<DetalleComboDto>.from(
                json['combos'].map((x) => DetalleComboDto.fromJson(x)),
              )
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
      'manillas': manillas.map((x) => x.toJson()).toList(),
      'mesas': mesas.map((x) => x.toJson()).toList(),
      'combos': combos.map((x) => x.toJson()).toList(),
    };
  }
}
