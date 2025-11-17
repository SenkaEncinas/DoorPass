class LoginDto {
  final String email;
  final String password;

  LoginDto({required this.email, required this.password});

  // Convertir el objeto a JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  // Crear un objeto desde JSON (por si el backend responde con datos similares)
  factory LoginDto.fromJson(Map<String, dynamic> json) {
    return LoginDto(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
