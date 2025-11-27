class UsuarioDto {
  final int id;
  final String nombre;
  final String email;
  final String rol;
  final int? bolicheId; // puede ser null
  final String token;

  UsuarioDto({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.bolicheId,
    required this.token,
  });

  factory UsuarioDto.fromJson(Map<String, dynamic> json) {
    return UsuarioDto(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
      bolicheId: json['bolicheId'],   // puede venir null
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'bolicheId': bolicheId,
      'token': token,
    };
  }
}
