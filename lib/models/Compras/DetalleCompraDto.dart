import 'package:doorpass/models/Compras/ItemCompraDto.dart';

class DetalleCompraDto {
  final int compraId;
  final DateTime fechaCompra;
  final double totalPagado;
  final String tipoCompra;

  final int bolicheId;
  final String nombreBoliche;

  final int usuarioId;
  final String nombreUsuario;
  final String emailUsuario;

  final String? mesaReservada;
  final List<ItemCompradoDto> manillasCompradas;

  DetalleCompraDto({
    required this.compraId,
    required this.fechaCompra,
    required this.totalPagado,
    required this.tipoCompra,
    required this.bolicheId,
    required this.nombreBoliche,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.emailUsuario,
    this.mesaReservada,
    required this.manillasCompradas,
  });

  factory DetalleCompraDto.fromJson(Map<String, dynamic> json) {
    return DetalleCompraDto(
      compraId: json['compraId'],
      fechaCompra: DateTime.parse(json['fechaCompra']),
      totalPagado: (json['totalPagado'] as num).toDouble(),
      tipoCompra: json['tipoCompra'],
      bolicheId: json['bolicheId'],
      nombreBoliche: json['nombreBoliche'],
      usuarioId: json['usuarioId'],
      nombreUsuario: json['nombreUsuario'],
      emailUsuario: json['emailUsuario'],
      mesaReservada: json['mesaReservada'],
      manillasCompradas:
          json['manillasCompradas'] != null
              ? (json['manillasCompradas'] as List)
                  .map((e) => ItemCompradoDto.fromJson(e))
                  .toList()
              : [],
    );
  }

  get usuarioNombre => null;

  get id => null;

  get total => null;

  get fecha => null;

  Map<String, dynamic> toJson() {
    return {
      'compraId': compraId,
      'fechaCompra': fechaCompra.toIso8601String(),
      'totalPagado': totalPagado,
      'tipoCompra': tipoCompra,
      'bolicheId': bolicheId,
      'nombreBoliche': nombreBoliche,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'emailUsuario': emailUsuario,
      'mesaReservada': mesaReservada,
      'manillasCompradas': manillasCompradas.map((e) => e.toJson()).toList(),
    };
  }
}
