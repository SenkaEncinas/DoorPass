// lib/screens/Admin/EdicionAdminBoliche.dart
import 'package:flutter/material.dart';
import 'package:doorpass/models/Productos/DetalleBolicheDto.dart';
import 'package:doorpass/models/Productos/DetalleBolichesSimpleDto.dart';
import 'package:doorpass/models/admin/CrearManillaTipoDto.dart';
import 'package:doorpass/models/admin/CrearMesaDto.dart';
import 'package:doorpass/models/admin/CrearStaffDto.dart';
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
  final ProductsService _productsService = ProductsService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boliche.nombre),
        backgroundColor: const Color(0xFF6A0DAD),
      ),
      body:
          _loading
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
                      _detalle!.direccion,
                      style: GoogleFonts.orbitron(
                        color: Colors.purpleAccent,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _seccionManillas(),
                    const SizedBox(height: 20),
                    _seccionMesas(),
                    const SizedBox(height: 20),
                    _seccionStaff(),
                  ],
                ),
              ),
      backgroundColor: const Color(0xFF100018),
    );
  }

  // Sección Manillas
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
            ElevatedButton(
              onPressed: _crearManilla,
              child: const Text('Nueva Manilla'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...?_detalle?.manillas.map(
          (m) => Text(
            '${m.nombre}: \$${m.precio} (Stock: ${m.stock})',
            style: GoogleFonts.orbitron(color: Colors.purpleAccent),
          ),
        ),
      ],
    );
  }

  // Sección Mesas
  Widget _seccionMesas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mesas:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: _crearMesa,
              child: const Text('Nueva Mesa'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...?_detalle?.mesas.map(
          (m) => Text(
            '${m.nombre}: \$${m.precio}',
            style: GoogleFonts.orbitron(color: Colors.purpleAccent),
          ),
        ),
      ],
    );
  }

  // Sección Staff
  Widget _seccionStaff() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Staff:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: _crearStaff,
              child: const Text('Nuevo Staff'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Lista de staff aún no implementada',
          style: TextStyle(color: Colors.purpleAccent),
        ),
      ],
    );
  }

  // Crear manilla
  void _crearManilla() {
    final nombreController = TextEditingController();
    final precioController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A0026),
            title: const Text(
              'Crear nueva manilla',
              style: TextStyle(color: Colors.white),
            ),
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
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final dto = CrearManillaTipoDto(
                    nombre: nombreController.text,
                    precio: double.tryParse(precioController.text) ?? 0,
                    stock: int.tryParse(stockController.text) ?? 0,
                  );
                  final nueva = await _adminService.crearManilla(
                    _detalle!.id,
                    dto,
                  );
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

  // Crear mesa
  void _crearMesa() {
    final nombreController = TextEditingController();
    final ubicacionController = TextEditingController();
    final precioController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A0026),
            title: const Text(
              'Crear nueva mesa',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campoTexto('Nombre o Número', nombreController),
                _campoTexto('Ubicación', ubicacionController),
                _campoTexto('Precio Reserva', precioController, isNumber: true),
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
                onPressed: () async {
                  final dto = CrearMesaDto(
                    nombreONumero: nombreController.text,
                    ubicacion: ubicacionController.text,
                    precioReserva: double.tryParse(precioController.text) ?? 0,
                  );
                  final nueva = await _adminService.crearMesa(
                    _detalle!.id,
                    dto,
                  );
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

  // Crear staff
  void _crearStaff() {
    final nombreController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A0026),
            title: const Text(
              'Crear nuevo Staff',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campoTexto('Nombre', nombreController),
                _campoTexto('Email', emailController),
                _campoTexto('Password', passwordController, isPassword: true),
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
                onPressed: () async {
                  final dto = CrearStaffDto(
                    nombre: nombreController.text,
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  final nuevo = await _adminService.crearStaff(dto);
                  if (nuevo != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Staff creado')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  Widget _campoTexto(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: isPassword,
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
