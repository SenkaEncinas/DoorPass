import 'dart:convert';
import 'package:doorpass/models/Auth/UsuarioDto.dart';
import 'package:doorpass/models/Entities/Combo.dart';
import 'package:doorpass/models/Productos/DetalleBolicheDto.dart';
import 'package:doorpass/models/Productos/DetalleManillaTipoDto.dart';
import 'package:doorpass/models/Productos/DetalleMesaDto.dart';
import 'package:doorpass/models/admin/CrearBolicheDto.dart';
import 'package:doorpass/models/admin/CrearComboDto.dart';
import 'package:doorpass/models/admin/CrearManillaTipoDto.dart';
import 'package:doorpass/models/admin/CrearMesaDto.dart';
import 'package:doorpass/models/admin/CrearStaffDto.dart';

// 👇 IMPORTA TUS DTOS DE UPDATE
import 'package:doorpass/models/admin/UpdateBolicheDto.dart';
import 'package:doorpass/models/admin/UpdateManillaTipoDto.dart';
import 'package:doorpass/models/admin/UpdateMesaDto.dart';
import 'package:doorpass/models/admin/UpdateComboDto.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  // Arreglo el doble slash
  final String _baseUrl =
      'https://app-251127122810.azurewebsites.net/api/admin';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ===================== BOLICHES =====================

  Future<DetalleBolicheDto?> crearBoliche(CrearBolicheDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/boliches'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return DetalleBolicheDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> actualizarBoliche(int id, UpdateBolicheDto dto) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/boliches/$id'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    return response.statusCode == 204;
  }

  Future<bool> eliminarBoliche(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/boliches/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }

  // ===================== MANILLAS =====================

  Future<DetalleManillaTipoDto?> crearManilla(
    int bolicheId,
    CrearManillaTipoDto dto,
  ) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/boliches/$bolicheId/manillas'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return DetalleManillaTipoDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> actualizarManilla(int id, UpdateManillaTipoDto dto) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/manillas/$id'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    return response.statusCode == 204;
  }

  Future<bool> eliminarManilla(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/manillas/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }

  // ===================== MESAS =====================

  Future<DetalleMesaDto?> crearMesa(int bolicheId, CrearMesaDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/boliches/$bolicheId/mesas'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return DetalleMesaDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> actualizarMesa(int id, UpdateMesaDto dto) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/mesas/$id'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    return response.statusCode == 204;
  }

  Future<bool> eliminarMesa(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/mesas/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }

  // ===================== STAFF =====================

  // POST api/admin/crear-staff
  Future<UsuarioDto?> crearStaff(CrearStaffDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/crear-staff'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return UsuarioDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // GET api/admin/boliches/{bolicheId}/staff
  Future<List<UsuarioDto>> getStaffPorBoliche(int bolicheId) async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/boliches/$bolicheId/staff'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => UsuarioDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  // DELETE api/admin/staff/{id}
  Future<bool> deleteStaff(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/staff/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }

  // ===================== COMBOS =====================

  Future<Combo?> crearCombo(int bolicheId, CrearComboDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/boliches/$bolicheId/combos'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return Combo.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> updateCombo(int id, UpdateComboDto dto) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/combos/$id'),
      headers: _headers(token),
      body: jsonEncode(dto.toJson()),
    );

    return response.statusCode == 204;
  }

  Future<bool> deleteCombo(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/combos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }
}
