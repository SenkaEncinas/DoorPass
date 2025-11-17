import 'Compra.dart';
import 'Combo.dart';

class CompraCombo {
  final int id;
  final int cantidad;
  final double precioEnElMomento;
  final int compraId;
  final Compra? compra;
  final int comboId;
  final Combo? combo;

  CompraCombo({
    required this.id,
    required this.cantidad,
    required this.precioEnElMomento,
    required this.compraId,
    this.compra,
    required this.comboId,
    this.combo,
  });

  factory CompraCombo.fromJson(Map<String, dynamic> json) {
    return CompraCombo(
      id: json['id'],
      cantidad: json['cantidad'],
      precioEnElMomento: (json['precioEnElMomento'] as num).toDouble(),
      compraId: json['compraId'],
      compra: json['compra'] != null ? Compra.fromJson(json['compra']) : null,
      comboId: json['comboId'],
      combo: json['combo'] != null ? Combo.fromJson(json['combo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cantidad': cantidad,
      'precioEnElMomento': precioEnElMomento,
      'compraId': compraId,
      'compra': compra?.toJson(),
      'comboId': comboId,
      'combo': combo?.toJson(),
    };
  }
}
