class DetalleMesaDto {
  final int id;
  final String nombreONumero;
  final String ubicacion;
  final double precioReserva;
  final bool estaDisponible;
  final int bolicheId;

  DetalleMesaDto({
    required this.id,
    required this.nombreONumero,
    required this.ubicacion,
    required this.precioReserva,
    required this.estaDisponible,
    required this.bolicheId,
  });

  factory DetalleMesaDto.fromJson(Map<String, dynamic> json) {
    return DetalleMesaDto(
      id: json['id'],
      nombreONumero: json['nombreONumero'],
      ubicacion: json['ubicacion'],
      precioReserva: (json['precioReserva'] as num).toDouble(),
      estaDisponible: json['estaDisponible'],
      bolicheId: json['bolicheId'],
    );
  }

  get nombre => null;

  get precio => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreONumero': nombreONumero,
      'ubicacion': ubicacion,
      'precioReserva': precioReserva,
      'estaDisponible': estaDisponible,
      'bolicheId': bolicheId,
    };
  }
}
