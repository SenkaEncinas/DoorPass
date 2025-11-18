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

  // ===================== Editar parámetros del Boliche =====================
  void _editarBoliche() {
    final nombreController = TextEditingController(text: _detalle!.nombre);
    final direccionController = TextEditingController(text: _detalle!.direccion ?? '');
    final descripcionController = TextEditingController(text: _detalle!.descripcion ?? '');
    final imagenController = TextEditingController(text: _detalle!.imagenUrl ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text('Editar Boliche', style: TextStyle(color: Colors.white)),
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
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
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
            child: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boliche.nombre),
        backgroundColor: const Color(0xFF6A0DAD),
      ),
      backgroundColor: const Color(0xFF100018),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            )
          : _detalle == null
              ? Center(
                  child: Text(
                    'No se pudo cargar el detalle',
                    style: GoogleFonts.orbitron(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _detalle!.nombre,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _detalle!.direccion ?? '',
                        style: GoogleFonts.orbitron(
                          color: Colors.purpleAccent,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _editarBoliche,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9D00FF),
                        ),
                        child: const Text('Editar Boliche'),
                      ),
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

  // ===================== Sección Manillas =====================
  Widget _seccionManillas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Manillas:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(onPressed: _crearManilla, child: const Text('Nueva Manilla')),
          ],
        ),
        const SizedBox(height: 8),
        ...?_detalle?.manillas.map(
          (m) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${m.nombre}: Bs. ${m.precio} (Stock: ${m.stock})',
                style: GoogleFonts.orbitron(color: Colors.purpleAccent),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _editarManilla(m),
                    icon: const Icon(Icons.edit, color: Colors.white70),
                  ),
                  IconButton(
                    onPressed: () => _eliminarManilla(m.id),
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _crearManilla() {
    final nombreController = TextEditingController();
    final precioController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text('Crear nueva manilla', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campoTexto('Nombre', nombreController),
            _campoTexto('Precio', precioController, isNumber: true),
            _campoTexto('Stock', stockController, isNumber: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () async {
              final dto = CrearManillaTipoDto(
                nombre: nombreController.text,
                precio: double.tryParse(precioController.text) ?? 0,
                stock: int.tryParse(stockController.text) ?? 0,
              );
              final nueva = await _adminService.crearManilla(_detalle!.id, dto);
              if (nueva != null) {
                _cargarDetalle();
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarManilla(DetalleManillaTipoDto manilla) {
    final nombreController = TextEditingController(text: manilla.nombre);
    final precioController = TextEditingController(text: manilla.precio.toString());
    final stockController = TextEditingController(text: manilla.stock.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text('Editar Manilla', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campoTexto('Nombre', nombreController),
            _campoTexto('Precio', precioController, isNumber: true),
            _campoTexto('Stock', stockController, isNumber: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () async {
              final dto = CrearManillaTipoDto(
                nombre: nombreController.text,
                precio: double.tryParse(precioController.text) ?? 0,
                stock: int.tryParse(stockController.text) ?? 0,
              );
              final success = await _adminService.actualizarManilla(manilla.id, dto);
              if (success) {
                _cargarDetalle();
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarManilla(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text('Eliminar Manilla', style: TextStyle(color: Colors.white)),
        content: const Text('¿Desea eliminar esta manilla?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success = await _adminService.eliminarManilla(id);
      if (success) _cargarDetalle();
    }
  }

  // ===================== Sección Mesas =====================
  Widget _seccionMesas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mesas:', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: _crearMesa, child: const Text('Nueva Mesa')),
          ],
        ),
        const SizedBox(height: 8),
        ...?_detalle?.mesas.map(
          (m) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${m.nombreONumero}: Bs. ${m.precioReserva}', style: GoogleFonts.orbitron(color: Colors.purpleAccent)),
              Row(
                children: [
                  IconButton(onPressed: () => _editarMesa(m), icon: const Icon(Icons.edit, color: Colors.white70)),
                  IconButton(onPressed: () => _eliminarMesa(m.id), icon: const Icon(Icons.delete, color: Colors.redAccent)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _crearMesa() {
    final nombreController = TextEditingController();
    final ubicacionController = TextEditingController();
    final precioController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text('Crear nueva mesa', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campoTexto('Nombre o Número', nombreController),
            _campoTexto('Ubicación', ubicacionController),
            _campoTexto('Precio Reserva', precioController, isNumber: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () async {
              final dto = CrearMesaDto(
                nombreONumero: nombreController.text,
                ubicacion: ubicacionController.text,
                precioReserva: double.tryParse(precioController.text) ?? 0,
              );
              final nueva = await _adminService.crearMesa(_detalle!.id, dto);
              if (nueva != null) {
                _cargarDetalle();
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarMesa(DetalleMesaDto mesa) {
    final nombreController = TextEditingController(text: mesa.nombreONumero);
    final ubicacionController = TextEditingController(text: mesa.ubicacion ?? '');
    final precioController = TextEditingController(text: mesa.precioReserva.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text('Editar Mesa', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campoTexto('Nombre o Número', nombreController),
            _campoTexto('Ubicación', ubicacionController),
            _campoTexto('Precio Reserva', precioController, isNumber: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () async {
              final dto = CrearMesaDto(
                nombreONumero: nombreController.text,
                ubicacion: ubicacionController.text,
                precioReserva: double.tryParse(precioController.text) ?? 0,
              );
              final success = await _adminService.actualizarMesa(mesa.id, dto);
              if (success) {
                _cargarDetalle();
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarMesa(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text('Eliminar Mesa', style: TextStyle(color: Colors.white)),
        content: const Text('¿Desea eliminar esta mesa?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success = await _adminService.eliminarMesa(id);
      if (success) _cargarDetalle();
    }
  }

  // ===================== Sección Staff =====================
  Widget _seccionStaff() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Staff:', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: _crearStaff, child: const Text('Nuevo Staff')),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Lista de staff aún no implementada', style: TextStyle(color: Colors.purpleAccent)),
      ],
    );
  }

  void _crearStaff() {
    final nombreController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text('Crear nuevo Staff', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campoTexto('Nombre', nombreController),
            _campoTexto('Email', emailController),
            _campoTexto('Password', passwordController, isPassword: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () async {
              final dto = CrearStaffDto(
                nombre: nombreController.text,
                email: emailController.text,
                password: passwordController.text,
              );
              final nuevo = await _adminService.crearStaff(dto);
              if (nuevo != null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff creado')));
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ===================== Sección Combos =====================
  Widget _seccionCombos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Combos:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: _crearCombo,
              child: const Text('Nuevo Combo'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...?_detalle?.combos.map(
          (c) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${c.nombre}: Bs. ${c.precio}', style: GoogleFonts.orbitron(color: Colors.purpleAccent)),
              Row(
                children: [
                  IconButton(onPressed: () => _editarCombo(c), icon: const Icon(Icons.edit, color: Colors.white70)),
                  IconButton(onPressed: () => _eliminarCombo(c.id), icon: const Icon(Icons.delete, color: Colors.redAccent)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _crearCombo() {
    final nombreController = TextEditingController();
    final precioController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text('Crear nuevo Combo', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campoTexto('Nombre', nombreController),
            _campoTexto('Precio', precioController, isNumber: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () async {
              final dto = CrearComboDto(
                nombre: nombreController.text,
                precio: double.tryParse(precioController.text) ?? 0,
              );
              final nuevo = await _adminService.crearCombo(_detalle!.id, dto);
              if (nuevo != null) {
                _cargarDetalle();
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarCombo(DetalleComboDto combo) {
    final nombreController = TextEditingController(text: combo.nombre);
    final precioController = TextEditingController(text: combo.precio.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text('Editar Combo', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campoTexto('Nombre', nombreController),
            _campoTexto('Precio', precioController, isNumber: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () async {
              final dto = CrearComboDto(
                nombre: nombreController.text,
                precio: double.tryParse(precioController.text) ?? 0,
              );
              final success = await _adminService.updateCombo(combo.id, dto);
              if (success) {
                _cargarDetalle();
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _eliminarCombo(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0026),
        title: const Text('Eliminar Combo', style: TextStyle(color: Colors.white)),
        content: const Text('¿Desea eliminar este combo?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success = await _adminService.deleteCombo(id);
      if (success) _cargarDetalle();
    }
  }

  // ===================== Campos de texto reutilizables =====================
  Widget _campoTexto(String label, TextEditingController controller,
      {bool isNumber = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.purpleAccent),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
