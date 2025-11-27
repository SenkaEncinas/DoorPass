class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String rol;      // "Admin", "Staff", "Usuario"
  final int? bolicheId;  // puede venir null

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.bolicheId,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
      bolicheId: json['bolicheId'], // puede ser null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'bolicheId': bolicheId,
    };
  }
}
