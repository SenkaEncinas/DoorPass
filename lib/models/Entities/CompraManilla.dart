import 'package:doorpass/models/Entities/Compra.dart';

import 'package:doorpass/models/Entities/ManillaTipo.dart';

class CompraManilla {
  final int id;
  final int cantidad;
  final double precioEnElMomento;
  final int compraId;
  final Compra compra;
  final int manillaTipoId;
  final ManillaTipo manillaTipo;

  CompraManilla({
    required this.id,
    required this.cantidad,
    required this.precioEnElMomento,
    required this.compraId,
    required this.compra,
    required this.manillaTipoId,
    required this.manillaTipo,
  });

  factory CompraManilla.fromJson(Map<String, dynamic> json) {
    return CompraManilla(
      id: json['id'],
      cantidad: json['cantidad'],
      precioEnElMomento: (json['precioEnElMomento'] as num).toDouble(),
      compraId: json['compraId'],
      compra: Compra.fromJson(json['compra']),
      manillaTipoId: json['manillaTipoId'],
      manillaTipo: ManillaTipo.fromJson(json['manillaTipo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cantidad': cantidad,
      'precioEnElMomento': precioEnElMomento,
      'compraId': compraId,
      'compra': compra.toJson(),
      'manillaTipoId': manillaTipoId,
      'manillaTipo': manillaTipo.toJson(),
    };
  }
}
