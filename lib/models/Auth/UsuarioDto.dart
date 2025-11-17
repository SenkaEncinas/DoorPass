class UsuarioDto {
  final int id;
  final String nombre;
  final String email;
  final String rol;
  final String token;

  UsuarioDto({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.token,
  });

  factory UsuarioDto.fromJson(Map<String, dynamic> json) {
    return UsuarioDto(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'token': token,
    };
  }
}
