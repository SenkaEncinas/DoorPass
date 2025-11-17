class CrearStaffDto {
  final String nombre;
  final String email;
  final String password;

  CrearStaffDto({
    required this.nombre,
    required this.email,
    required this.password,
  });

  factory CrearStaffDto.fromJson(Map<String, dynamic> json) {
    return CrearStaffDto(
      nombre: json['nombre'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'email': email, 'password': password};
  }
}
