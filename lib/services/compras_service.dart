import 'dart:convert';
import 'package:doorpass/models/Compras/CrearCompraManilla.dart';
import 'package:doorpass/models/Compras/DetalleCompraDto.dart';
import 'package:doorpass/models/Compras/ReservarMesaDto.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ComprasService {
  final String _baseUrl =
      'https://app-251115115117.azurewebsites.net/api/compras';
  final AuthService _authService = AuthService();

  // Comprar manillas
  Future<DetalleCompraDto?> comprarManillas(CrearCompraManillasDto dto) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/manillas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return DetalleCompraDto.fromJson(jsonDecode(response.body));
    } else {
      print('Error comprar manillas: ${response.body}');
      return null;
    }
  }

  // Reservar mesa
  Future<DetalleCompraDto?> reservarMesa(ReservarMesaDto dto) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/mesas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return DetalleCompraDto.fromJson(jsonDecode(response.body));
    } else {
      print('Error reservar mesa: ${response.body}');
      return null;
    }
  }

  // Historial de compras del usuario
  Future<List<DetalleCompraDto>> getHistorial() async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/mi-historial'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => DetalleCompraDto.fromJson(json)).toList();
    } else {
      print('Error historial compras: ${response.body}');
      return [];
    }
  }
}
