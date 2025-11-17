class RegistroDto {
  final String nombre;
  final String email;
  final String password;

  RegistroDto({
    required this.nombre,
    required this.email,
    required this.password,
  });

  // Convertir el objeto a JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'email': email, 'password': password};
  }

  // Crear un objeto desde JSON
  factory RegistroDto.fromJson(Map<String, dynamic> json) {
    return RegistroDto(
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
