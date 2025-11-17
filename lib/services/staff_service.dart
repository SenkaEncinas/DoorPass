import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doorpass/models/Compras/DetalleCompraDto.dart';
import 'auth_service.dart';

class StaffService {
  final String _baseUrl =
      'https://app-251115115117.azurewebsites.net/api/staff';
  final AuthService _authService = AuthService();

  // Obtener historial de compras de todos los usuarios
  Future<List<DetalleCompraDto>> getHistorialCompras() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/historial'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => DetalleCompraDto.fromJson(json)).toList();
    } else {
      print('Error al obtener historial: ${response.body}');
      return [];
    }
  }
}
