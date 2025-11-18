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
      backgroundColor: const Color(0xFF100018),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A0DAD),
        title: Text(
          'Administrador de Boliches',
          style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
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
          ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: boliches.length,
              itemBuilder: (context, index) {
                final boliche = boliches[index];
                return Card(
                  color: const Color(0xFF2D014F).withOpacity(0.9),
                  elevation: 6,
                  shadowColor: Colors.purpleAccent.withOpacity(0.6),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: boliche.imagenUrl != null && boliche.imagenUrl!.isNotEmpty
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
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      boliche.direccion,
                      style: GoogleFonts.orbitron(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EdicionAdminBoliche(boliche: boliche),
                              ),
                            );
                            _cargarBoliches();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFF2D014F),
                                title: Text(
                                  'Confirmar eliminación',
                                  style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                content: Text(
                                  '¿Estás seguro de eliminar "${boliche.nombre}"?',
                                  style: GoogleFonts.orbitron(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(
                                      'Cancelar',
                                      style: GoogleFonts.orbitron(color: Colors.white70),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(
                                      'Eliminar',
                                      style: GoogleFonts.orbitron(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final ok = await _adminService.eliminarBoliche(boliche.id);
                              if (ok) {
                                _cargarBoliches();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Boliche "${boliche.nombre}" eliminado',
                                      style: GoogleFonts.orbitron(),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al eliminar boliche',
                                      style: GoogleFonts.orbitron(),
                                    ),
                                  ),
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
        backgroundColor: const Color(0xFF2D014F),
        title: Text(
          'Crear nuevo boliche',
          style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
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
            child: Text(
              'Cancelar',
              style: GoogleFonts.orbitron(color: Colors.white70),
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
                  imagenUrl: imagenController.text.isNotEmpty ? imagenController.text : null,
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
                  SnackBar(
                    content: Text(
                      'Error al crear boliche',
                      style: GoogleFonts.orbitron(),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'Guardar',
              style: GoogleFonts.orbitron(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoTexto(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.orbitron(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.orbitron(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
