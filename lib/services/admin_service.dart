import 'dart:convert';
import 'package:doorpass/models/Auth/UsuarioDto.dart';
import 'package:doorpass/models/Productos/DetalleBolicheDto.dart';
import 'package:doorpass/models/Productos/DetalleManillaTipoDto.dart';
import 'package:doorpass/models/Productos/DetalleMesaDto.dart';
import 'package:doorpass/models/admin/CrearBolicheDto.dart';
import 'package:doorpass/models/admin/CrearManillaTipoDto.dart';
import 'package:doorpass/models/admin/CrearMesaDto.dart';
import 'package:doorpass/models/admin/CrearStaffDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  final String _baseUrl =
      'https://app-251115115117.azurewebsites.net/api/admin';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<DetalleBolicheDto?> crearBoliche(CrearBolicheDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/boliches'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return DetalleBolicheDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<DetalleManillaTipoDto?> crearManilla(
    int bolicheId,
    CrearManillaTipoDto dto,
  ) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/boliches/$bolicheId/manillas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return DetalleManillaTipoDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<DetalleMesaDto?> crearMesa(int bolicheId, CrearMesaDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/boliches/$bolicheId/mesas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return DetalleMesaDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<UsuarioDto?> crearStaff(CrearStaffDto dto) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/crear-staff'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      return UsuarioDto.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}
