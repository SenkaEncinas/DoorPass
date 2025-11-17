import 'package:doorpass/models/Entities/Boliche.dart';
import 'package:doorpass/models/Entities/Compra.dart';

class Mesa {
  final int id;
  final String nombreONumero;
  final String? ubicacion;
  final double precioReserva;
  final bool estaDisponible;
  final int bolicheId;
  final Boliche boliche;
  final int? compraId;
  final Compra? compra;

  Mesa({
    required this.id,
    required this.nombreONumero,
    this.ubicacion,
    required this.precioReserva,
    this.estaDisponible = true,
    required this.bolicheId,
    required this.boliche,
    this.compraId,
    this.compra,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: json['id'],
      nombreONumero: json['nombreONumero'],
      ubicacion: json['ubicacion'],
      precioReserva: (json['precioReserva'] as num).toDouble(),
      estaDisponible: json['estaDisponible'] ?? true,
      bolicheId: json['bolicheId'],
      boliche: Boliche.fromJson(json['boliche']),
      compraId: json['compraId'],
      compra: json['compra'] != null ? Compra.fromJson(json['compra']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreONumero': nombreONumero,
      'ubicacion': ubicacion,
      'precioReserva': precioReserva,
      'estaDisponible': estaDisponible,
      'bolicheId': bolicheId,
      'boliche': boliche.toJson(),
      'compraId': compraId,
      'compra': compra?.toJson(),
    };
  }
}
