class UpdateMesaDto {
  final String nombreONumero;
  final String? ubicacion;
  final double precioReserva;
  final bool estaDisponible;

  UpdateMesaDto({
    required this.nombreONumero,
    this.ubicacion,
    required this.precioReserva,
    required this.estaDisponible,
  });

  factory UpdateMesaDto.fromJson(Map<String, dynamic> json) {
    return UpdateMesaDto(
      nombreONumero: json['nombreONumero'],
      ubicacion: json['ubicacion'],
      precioReserva: (json['precioReserva'] as num).toDouble(),
      estaDisponible: json['estaDisponible'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreONumero': nombreONumero,
      'ubicacion': ubicacion,
      'precioReserva': precioReserva,
      'estaDisponible': estaDisponible,
    };
  }
}
