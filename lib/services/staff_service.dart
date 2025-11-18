import 'dart:convert';
import 'package:doorpass/models/Compras/DetalleCompraDto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StaffService {
  final String _baseUrl =
      'https://app-251117192144.azurewebsites.net/api/staff';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- HISTORIAL DE COMPRAS PARA STAFF/ADMIN ---
  Future<List<DetalleCompraDto>> getHistorialCompras() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/historial'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => DetalleCompraDto.fromJson(json)).toList();
    }
    return [];
  }
}
