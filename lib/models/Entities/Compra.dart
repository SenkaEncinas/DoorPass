import 'Boliche.dart';
import 'Usuario.dart';
import 'Mesa.dart';
import 'CompraManilla.dart';
import 'CompraCombo.dart';

class Compra {
  final int id;
  final DateTime fechaCompra;
  final double totalPagado;
  final String tipoCompra; // "Manillas", "Reserva de Mesa" o "Combos"
  final bool estaActiva;

  final int usuarioId;
  final Usuario? usuario;

  final int bolicheId;
  final Boliche? boliche;

  final List<CompraManilla> manillasCompradas;
  final List<CompraCombo> combosComprados;
  final Mesa? mesaReservada;

  Compra({
    required this.id,
    DateTime? fechaCompra,
    required this.totalPagado,
    required this.tipoCompra,
    this.estaActiva = true,
    required this.usuarioId,
    this.usuario,
    required this.bolicheId,
    this.boliche,
    this.manillasCompradas = const [],
    this.combosComprados = const [],
    this.mesaReservada,
  }) : fechaCompra = fechaCompra ?? DateTime.now();

  factory Compra.fromJson(Map<String, dynamic> json) {
    return Compra(
      id: json['id'],
      fechaCompra:
          json['fechaCompra'] != null
              ? DateTime.parse(json['fechaCompra'])
              : DateTime.now(),
      totalPagado: (json['totalPagado'] as num).toDouble(),
      tipoCompra: json['tipoCompra'],
      estaActiva: json['estaActiva'] ?? true,
      usuarioId: json['usuarioId'],
      usuario:
          json['usuario'] != null ? Usuario.fromJson(json['usuario']) : null,
      bolicheId: json['bolicheId'],
      boliche:
          json['boliche'] != null ? Boliche.fromJson(json['boliche']) : null,
      manillasCompradas:
          json['manillasCompradas'] != null
              ? List<CompraManilla>.from(
                json['manillasCompradas'].map((x) => CompraManilla.fromJson(x)),
              )
              : [],
      combosComprados:
          json['combosComprados'] != null
              ? List<CompraCombo>.from(
                json['combosComprados'].map((x) => CompraCombo.fromJson(x)),
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
      'estaActiva': estaActiva,
      'usuarioId': usuarioId,
      'usuario': usuario?.toJson(),
      'bolicheId': bolicheId,
      'boliche': boliche?.toJson(),
      'manillasCompradas': manillasCompradas.map((x) => x.toJson()).toList(),
      'combosComprados': combosComprados.map((x) => x.toJson()).toList(),
      'mesaReservada': mesaReservada?.toJson(),
    };
  }
}
