// lib/screens/Admin/AdminBolichesScreen.dart
import 'package:flutter/material.dart';
import 'package:doorpass/models/Productos/DetalleBolichesSimpleDto.dart';
import 'package:doorpass/screens/Admin/EdicionAdminBoliche.dart';
import 'package:doorpass/screens/LoginScreen.dart';
import 'package:doorpass/models/admin/CrearBolicheDto.dart';
import 'package:doorpass/services/admin_service.dart';
import 'package:doorpass/services/productos_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminBolichesScreen extends StatefulWidget {
  const AdminBolichesScreen({super.key});

  @override
  State<AdminBolichesScreen> createState() => _AdminBolichesScreenState();
}

class _AdminBolichesScreenState extends State<AdminBolichesScreen> {
  final ProductsService _productsService = ProductsService();
  final AdminService _adminService = AdminService();

  List<DetalleBolicheSimpleDto> boliches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarBoliches();
  }

  Future<void> _cargarBoliches() async {
    setState(() => _loading = true);
    boliches = await _productsService.getBoliches();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A0DAD),
        title: const Text(
          'Administrador de Boliches',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9D00FF),
        onPressed: _mostrarDialogoCrear,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.purpleAccent),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: boliches.length,
                itemBuilder: (context, index) {
                  final boliche = boliches[index];
                  return Card(
                    color: const Color(0xFF1A0026),
                    elevation: 6,
                    shadowColor: Colors.purpleAccent,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      textColor: Colors.white,
                      title: Text(
                        boliche.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        boliche.direccion,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () async {
                          // Redirigir a la pantalla de edición de boliche
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      EdicionAdminBoliche(boliche: boliche),
                            ),
                          );
                          // Recargar la lista al volver
                          _cargarBoliches();
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }

  void _mostrarDialogoCrear() {
    final nombreController = TextEditingController();
    final direccionController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A0026),
            title: const Text(
              'Crear nuevo boliche',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campoTexto('Nombre', nombreController),
                _campoTexto('Dirección', direccionController),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D00FF),
                ),
                onPressed: () async {
                  if (nombreController.text.isEmpty ||
                      direccionController.text.isEmpty)
                    return;

                  final nuevoBoliche = await _adminService.crearBoliche(
                    CrearBolicheDto(
                      nombre: nombreController.text,
                      direccion: direccionController.text,
                    ),
                  );

                  if (nuevoBoliche != null) {
                    boliches.add(
                      DetalleBolicheSimpleDto(
                        id: nuevoBoliche.id,
                        nombre: nuevoBoliche.nombre,
                        direccion: nuevoBoliche.direccion,
                      ),
                    );
                    setState(() {});
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al crear boliche')),
                    );
                  }
                },
                child: const Text(
                  'Guardar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _campoTexto(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white38),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.purpleAccent),
          ),
        ),
      ),
    );
  }
}
