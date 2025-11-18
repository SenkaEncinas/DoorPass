// lib/screens/Admin/EdicionAdminBoliche.dart
import 'package:doorpass/models/Entities/Combo.dart';
import 'package:doorpass/models/Productos/DetalleComboDto.dart';
import 'package:doorpass/models/Productos/DetalleManillaTipoDto.dart';
import 'package:doorpass/models/Productos/DetalleMesaDto.dart';
import 'package:flutter/material.dart';
import 'package:doorpass/models/Productos/DetalleBolicheDto.dart';
import 'package:doorpass/models/Productos/DetalleBolichesSimpleDto.dart';
import 'package:doorpass/models/admin/CrearManillaTipoDto.dart';
import 'package:doorpass/models/admin/CrearMesaDto.dart';
import 'package:doorpass/models/admin/CrearStaffDto.dart';
import 'package:doorpass/models/admin/CrearComboDto.dart';
import 'package:doorpass/models/admin/CrearBolicheDto.dart';
import 'package:doorpass/services/admin_service.dart';
import 'package:doorpass/services/productos_service.dart';
import 'package:google_fonts/google_fonts.dart';

class EdicionAdminBoliche extends StatefulWidget {
  final DetalleBolicheSimpleDto boliche;
  const EdicionAdminBoliche({super.key, required this.boliche});

  @override
  State<EdicionAdminBoliche> createState() => _EdicionAdminBolicheState();
}

class _EdicionAdminBolicheState extends State<EdicionAdminBoliche> {
  final ProductosService _productsService = ProductosService();
  final AdminService _adminService = AdminService();
  DetalleBolicheDto? _detalle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    final detalle = await _productsService.getBolicheDetalle(widget.boliche.id);
    setState(() {
      _detalle = detalle;
      _loading = false;
    });
  }

  void _editarBoliche() {
    final nombreController = TextEditingController(text: _detalle!.nombre);
    final direccionController = TextEditingController(text: _detalle!.direccion ?? '');
    final descripcionController = TextEditingController(text: _detalle!.descripcion ?? '');
    final imagenController = TextEditingController(text: _detalle!.imagenUrl ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: Text('Editar Boliche', style: GoogleFonts.orbitron(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campoTexto('Nombre', nombreController),
              _campoTexto('Dirección', direccionController),
              _campoTexto('Descripción', descripcionController),
              _campoTexto('URL de Imagen', imagenController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.orbitron(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreController.text.trim();
              final direccion = direccionController.text.trim();
              final descripcion = descripcionController.text.trim();
              final imagen = imagenController.text.trim();

              if (nombre.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nombre es obligatorio')),
                );
                return;
              }

              final dto = CrearBolicheDto(
                nombre: nombre,
                direccion: direccion,
                descripcion: descripcion.isNotEmpty ? descripcion : '',
                imagenUrl: imagen.isNotEmpty ? imagen : null,
              );

              final success = await _adminService.actualizarBoliche(_detalle!.id, dto);

              if (success) {
                _cargarDetalle();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Boliche actualizado correctamente')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al actualizar el boliche')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9D00FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Guardar cambios', style: GoogleFonts.orbitron(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(
    widget.boliche.nombre,
    style: GoogleFonts.orbitron(
      color: Colors.white, // Mantiene el color de texto
      fontWeight: FontWeight.bold, // Igual que otros títulos
      fontSize: 22, // Ajustable al gusto
    ),
  ),
  backgroundColor: const Color(0xFF6A0DAD),
),

      backgroundColor: const Color(0xFF100018),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
          : _detalle == null
              ? Center(child: Text('No se pudo cargar el detalle', style: GoogleFonts.orbitron(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cabeceraBoliche(),
                      const SizedBox(height: 20),
                      _seccionManillas(),
                      const SizedBox(height: 20),
                      _seccionMesas(),
                      const SizedBox(height: 20),
                      _seccionStaff(),
                      const SizedBox(height: 20),
                      _seccionCombos(),
                    ],
                  ),
                ),
    );
  }

  Widget _cabeceraBoliche() {
    return Card(
      color: const Color(0xFF1A0026),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_detalle!.nombre, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_detalle!.direccion ?? '', style: GoogleFonts.orbitron(color: Colors.purpleAccent, fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _editarBoliche,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9D00FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Editar Boliche', style: GoogleFonts.orbitron()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionCard(String titulo, VoidCallback onCrear, List<Widget> items) {
    return Card(
      color: const Color(0xFF1A0026),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(titulo, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton(onPressed: onCrear, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9D00FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text('Nuevo', style: GoogleFonts.orbitron())),
            ]),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  // ===================== Secciones =====================
  Widget _seccionManillas() {
    final items = _detalle?.manillas.map((m) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${m.nombre}: Bs. ${m.precio} (Stock: ${m.stock})', style: GoogleFonts.orbitron(color: Colors.purpleAccent)),
            Row(children: [
              IconButton(onPressed: () => _editarManilla(m), icon: const Icon(Icons.edit, color: Colors.white70)),
              IconButton(onPressed: () => _eliminarManilla(m.id), icon: const Icon(Icons.delete, color: Colors.redAccent)),
            ]),
          ],
        )).toList() ?? [];
    return _seccionCard('Manillas', _crearManilla, items);
  }

  Widget _seccionMesas() {
    final items = _detalle?.mesas.map((m) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${m.nombreONumero}: Bs. ${m.precioReserva}', style: GoogleFonts.orbitron(color: Colors.purpleAccent)),
            Row(children: [
              IconButton(onPressed: () => _editarMesa(m), icon: const Icon(Icons.edit, color: Colors.white70)),
              IconButton(onPressed: () => _eliminarMesa(m.id), icon: const Icon(Icons.delete, color: Colors.redAccent)),
            ]),
          ],
        )).toList() ?? [];
    return _seccionCard('Mesas', _crearMesa, items);
  }

  Widget _seccionStaff() {
    final items = [Text('Staff', style: GoogleFonts.orbitron(color: Colors.purpleAccent))];
    return _seccionCard('Staff', _crearStaff, items);
  }

  Widget _seccionCombos() {
    final items = _detalle?.combos.map((c) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${c.nombre}: Bs. ${c.precio}', style: GoogleFonts.orbitron(color: Colors.purpleAccent)),
            Row(children: [
              IconButton(onPressed: () => _editarCombo(c), icon: const Icon(Icons.edit, color: Colors.white70)),
              IconButton(onPressed: () => _eliminarCombo(c.id), icon: const Icon(Icons.delete, color: Colors.redAccent)),
            ]),
          ],
        )).toList() ?? [];
    return _seccionCard('Combos', _crearCombo, items);
  }

  // ===================== Campos de texto =====================
  Widget _campoTexto(String label, TextEditingController controller, {bool isNumber = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: isPassword,
        style: GoogleFonts.orbitron(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.orbitron(color: Colors.white70),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.purpleAccent)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
      ),
    );
  }

  // ===================== Métodos CRUD sin cambios =====================
  void _crearManilla() {}
  void _editarManilla(DetalleManillaTipoDto manilla) {}
  void _eliminarManilla(int id) {}

  void _crearMesa() {}
  void _editarMesa(DetalleMesaDto mesa) {}
  void _eliminarMesa(int id) {}

  void _crearStaff() {}

  void _crearCombo() {}
  void _editarCombo(DetalleComboDto combo) {}
  void _eliminarCombo(int id) {}
}
