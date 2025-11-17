import 'package:doorpass/models/Entities/Boliche.dart';
import 'package:doorpass/models/Entities/Usuario.dart';
import 'package:doorpass/models/Entities/Mesa.dart';
import 'package:doorpass/models/Entities/CompraManilla.dart';

class Compra {
  final int id;
  final DateTime fechaCompra;
  final double totalPagado;
  final String tipoCompra; // "Manillas" o "Reserva de Mesa"
  final int usuarioId;
  final Usuario usuario;
  final int bolicheId;
  final Boliche boliche;
  final List<CompraManilla> manillasCompradas;
  final Mesa? mesaReservada;

  Compra({
    required this.id,
    required this.fechaCompra,
    required this.totalPagado,
    required this.tipoCompra,
    required this.usuarioId,
    required this.usuario,
    required this.bolicheId,
    required this.boliche,
    this.manillasCompradas = const [],
    this.mesaReservada,
  });

  factory Compra.fromJson(Map<String, dynamic> json) {
    return Compra(
      id: json['id'],
      fechaCompra: DateTime.parse(json['fechaCompra']),
      totalPagado: (json['totalPagado'] as num).toDouble(),
      tipoCompra: json['tipoCompra'],
      usuarioId: json['usuarioId'],
      usuario: Usuario.fromJson(json['usuario']),
      bolicheId: json['bolicheId'],
      boliche: Boliche.fromJson(json['boliche']),
      manillasCompradas:
          json['manillasCompradas'] != null
              ? List<CompraManilla>.from(
                json['manillasCompradas'].map((x) => CompraManilla.fromJson(x)),
              )
              : [],
      mesaReservada:
          json['mesaReservada'] != null
              ? Mesa.fromJson(json['mesaReservada'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaCompra': fechaCompra.toIso8601String(),
      'totalPagado': totalPagado,
      'tipoCompra': tipoCompra,
      'usuarioId': usuarioId,
      'usuario': usuario.toJson(),
      'bolicheId': bolicheId,
      'boliche': boliche.toJson(),
      'manillasCompradas': manillasCompradas.map((x) => x.toJson()).toList(),
      'mesaReservada': mesaReservada?.toJson(),
    };
  }
}
