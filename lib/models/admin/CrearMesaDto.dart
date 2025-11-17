class CrearMesaDto {
  final String nombreONumero;
  final String? ubicacion;
  final double precioReserva;

  CrearMesaDto({
    required this.nombreONumero,
    this.ubicacion,
    required this.precioReserva,
  });

  factory CrearMesaDto.fromJson(Map<String, dynamic> json) {
    return CrearMesaDto(
      nombreONumero: json['nombreONumero'],
      ubicacion: json['ubicacion'],
      precioReserva: (json['precioReserva'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreONumero': nombreONumero,
      'ubicacion': ubicacion,
      'precioReserva': precioReserva,
    };
  }
}
