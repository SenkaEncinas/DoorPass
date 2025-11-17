import 'dart:convert';
import 'package:doorpass/models/Compras/CrearCompraManilla.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Compras/DetalleCompraDto.dart';
import '../models/Compras/CrearCompraCombosDto.dart';
import '../models/Compras/ReservarMesaDto.dart';

class ComprasService {
  final String _baseUrl =
      'https://app-251116165954.azurewebsites.net/api/compras';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- COMPRAR MANILLAS ---
  Future<DetalleCompraDto?> comprarManillas(CrearCompraManillasDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

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
    }
    return null;
  }

  // --- RESERVAR MESA ---
  Future<DetalleCompraDto?> reservarMesa(ReservarMesaDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

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
    }
    return null;
  }

  // --- COMPRAR COMBOS ---
  Future<DetalleCompraDto?> comprarCombos(CrearCompraCombosDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/combos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return DetalleCompraDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // --- HISTORIAL DEL USUARIO ---
  Future<List<DetalleCompraDto>> getMiHistorial() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/mi-historial'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => DetalleCompraDto.fromJson(json)).toList();
    }
    return [];
  }

  // --- CANCELAR COMPRA ---
  Future<bool> cancelarCompra(int compraId) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.patch(
      Uri.parse('$_baseUrl/cancelar/$compraId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }
}
