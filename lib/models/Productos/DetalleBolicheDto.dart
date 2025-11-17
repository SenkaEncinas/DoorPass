import 'package:doorpass/models/Productos/DetalleManillaTipoDto.dart';
import 'package:doorpass/models/Productos/DetalleMesaDto.dart';

class DetalleBolicheDto {
  final int id;
  final String nombre;
  final String direccion;
  final List<DetalleManillaTipoDto> manillas;
  final List<DetalleMesaDto> mesas;

  DetalleBolicheDto({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.manillas,
    required this.mesas,
  });

  factory DetalleBolicheDto.fromJson(Map<String, dynamic> json) {
    return DetalleBolicheDto(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      manillas:
          (json['manillas'] as List<dynamic>)
              .map((e) => DetalleManillaTipoDto.fromJson(e))
              .toList(),
      mesas:
          (json['mesas'] as List<dynamic>)
              .map((e) => DetalleMesaDto.fromJson(e))
              .toList(),
    );
  }

  get descripcion => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'manillas': manillas.map((e) => e.toJson()).toList(),
      'mesas': mesas.map((e) => e.toJson()).toList(),
    };
  }
}
