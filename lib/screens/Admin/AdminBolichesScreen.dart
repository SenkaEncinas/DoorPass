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
  final ProductosService _productsService = ProductosService();
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
    try {
      final lista = await _productsService.getBoliches();
      setState(() => boliches = lista);
    } catch (e) {
      debugPrint('Error cargando boliches: $e');
    } finally {
      setState(() => _loading = false);
    }
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
                MaterialPageRoute(builder: (_) => const LoginScreen()),
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
      body: _loading
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: boliche.imagenUrl != null &&
                            boliche.imagenUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              boliche.imagenUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                    title: Text(
                      boliche.nombre,
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      boliche.direccion,
                      style: GoogleFonts.orbitron(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ===== BOTÓN EDITAR =====
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EdicionAdminBoliche(boliche: boliche),
                              ),
                            );
                            _cargarBoliches();
                          },
                        ),
                        // ===== BOTÓN ELIMINAR =====
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFF1A0026),
                                title: const Text(
                                  'Confirmar eliminación',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  '¿Estás seguro de eliminar "${boliche.nombre}"?',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final ok =
                                  await _adminService.eliminarBoliche(boliche.id);
                              if (ok) {
                                _cargarBoliches();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Boliche "${boliche.nombre}" eliminado')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Error al eliminar boliche')),
                                );
                              }
                            }
                          },
                        ),
                      ],
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
    final descripcionController = TextEditingController();
    final imagenController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text(
          'Crear nuevo boliche',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campoTexto('Nombre', nombreController),
              _campoTexto('Dirección', direccionController),
              _campoTexto('Descripción', descripcionController),
              _campoTexto('Imagen URL (opcional)', imagenController),
            ],
          ),
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
                  direccionController.text.isEmpty ||
                  descripcionController.text.isEmpty) return;

              final nuevoBoliche = await _adminService.crearBoliche(
                CrearBolicheDto(
                  nombre: nombreController.text,
                  direccion: direccionController.text,
                  descripcion: descripcionController.text,
                  imagenUrl: imagenController.text.isNotEmpty
                      ? imagenController.text
                      : null,
                ),
              );

              if (nuevoBoliche != null) {
                boliches.add(
                  DetalleBolicheSimpleDto(
                    id: nuevoBoliche.id,
                    nombre: nuevoBoliche.nombre,
                    direccion: nuevoBoliche.direccion ?? '',
                    imagenUrl: nuevoBoliche.imagenUrl ?? '',
                    descripcion: '',
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
