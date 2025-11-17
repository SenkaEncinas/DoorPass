import 'dart:convert';
import 'package:doorpass/models/Productos/DetalleBolicheDto.dart';
import 'package:doorpass/models/Productos/DetalleBolichesSimpleDto.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ProductsService {
  final String _baseUrl =
      'https://app-251115115117.azurewebsites.net/api/productos';
  final AuthService _authService = AuthService();

  // Obtener todos los boliches
  Future<List<DetalleBolicheSimpleDto>> getBoliches() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/boliches'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((json) => DetalleBolicheSimpleDto.fromJson(json))
          .toList();
    } else {
      print('Error al obtener boliches: ${response.body}');
      return [];
    }
  }

  // Obtener detalle de un boliche por ID
  Future<DetalleBolicheDto?> getBolicheDetalle(int bolicheId) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/boliches/$bolicheId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DetalleBolicheDto.fromJson(jsonDecode(response.body));
    } else {
      print('Error al obtener detalle boliche: ${response.body}');
      return null;
    }
  }
}
