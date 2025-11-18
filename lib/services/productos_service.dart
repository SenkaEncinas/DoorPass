import 'dart:convert';
import 'package:doorpass/models/Productos/DetalleBolicheDto.dart';
import 'package:doorpass/models/Productos/DetalleBolichesSimpleDto.dart';
import 'package:doorpass/models/Productos/DetalleManillaTipoDto.dart';
import 'package:doorpass/models/Productos/DetalleMesaDto.dart';
import 'package:doorpass/models/Productos/DetalleComboDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductosService {
  final String _baseUrl =
      'https://app-251117192144.azurewebsites.net/api/productos';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ============================================
  //             LISTAR BOLICHES
  // ============================================
  Future<List<DetalleBolicheSimpleDto>> getBoliches() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/boliches'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list
          .map((json) => DetalleBolicheSimpleDto.fromJson(json))
          .toList();
    }
    return [];
  }

  // ============================================
  //          DETALLE DE UN BOLICHE
  // ============================================
  Future<DetalleBolicheDto?> getBolicheDetalle(int bolicheId) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/boliches/$bolicheId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return DetalleBolicheDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // ============================================
  //        MANILLAS DE UN BOLICHE
  // ============================================
  Future<List<DetalleManillaTipoDto>> getManillasPorBoliche(
    int bolicheId,
  ) async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/boliches/$bolicheId/manillas'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list
          .map((json) => DetalleManillaTipoDto.fromJson(json))
          .toList();
    }
    return [];
  }

  // ============================================
  //        MESAS DISPONIBLES POR BOLICHE
  // ============================================
  Future<List<DetalleMesaDto>> getMesasPorBoliche(int bolicheId) async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/boliches/$bolicheId/mesas'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list
          .map((json) => DetalleMesaDto.fromJson(json))
          .toList();
    }
    return [];
  }

  // ============================================
  //        COMBOS POR BOLICHE
  // ============================================
  Future<List<DetalleComboDto>> getCombosPorBoliche(int bolicheId) async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/boliches/$bolicheId/combos'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list
          .map((json) => DetalleComboDto.fromJson(json))
          .toList();
    }
    return [];
  }
}
