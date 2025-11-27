class CrearStaffDto {
  final String nombre;
  final String email;
  final String password;
  final int bolicheId;

  CrearStaffDto({
    required this.nombre,
    required this.email,
    required this.password,
    required this.bolicheId,
  });

  factory CrearStaffDto.fromJson(Map<String, dynamic> json) {
    return CrearStaffDto(
      nombre: json['nombre'],
      email: json['email'],
      password: json['password'],
      bolicheId: json['bolicheId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'password': password,
      'bolicheId': bolicheId,
    };
  }
}
