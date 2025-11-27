import 'dart:convert';
import 'package:doorpass/models/Auth/LoginDto.dart';
import 'package:doorpass/models/Auth/RegistroDto.dart';
import 'package:doorpass/models/Auth/UsuarioDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'https://app-251127122810.azurewebsites.net/api/auth';

  // Registro
  Future<UsuarioDto?> register(RegistroDto dto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final usuario = UsuarioDto.fromJson(jsonDecode(response.body));
      await saveToken(usuario.token);
      return usuario;
    } else {
      print('Error register: ${response.body}');
      return null;
    }
  }

  // Login
  Future<UsuarioDto?> login(LoginDto dto, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final usuario = UsuarioDto.fromJson(jsonDecode(response.body));
      await saveToken(usuario.token);
      return usuario;
    } else {
      print('Error login: ${response.body}');
      return null;
    }
  }

  // Guardar token localmente
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Obtener token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
