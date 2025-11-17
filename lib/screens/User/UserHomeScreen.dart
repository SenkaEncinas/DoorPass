import 'package:doorpass/models/Productos/DetalleBolicheDto.dart';
import 'package:doorpass/models/Productos/DetalleBolichesSimpleDto.dart';
import 'package:doorpass/screens/LoginScreen.dart';
import 'package:doorpass/screens/User/ComprasScreen.dart';
import 'package:doorpass/services/productos_service.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HistorialComprasScreen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductsService _productsService = ProductsService();

  List<DetalleBolicheSimpleDto> boliches = [];
  DetalleBolicheDto? _seleccionado;
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

  Future<void> _cargarDetalle(int bolicheId) async {
    try {
      final detalle = await _productsService.getBolicheDetalle(bolicheId);
      if (detalle != null) {
        setState(() => _seleccionado = detalle);
      }
    } catch (e) {
      debugPrint('Error cargando detalle: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFF100018),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D014F),
        title: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurpleAccent.withOpacity(0.6),
                Colors.purpleAccent.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.orbitron(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              hintText: 'Buscar boliche...',
              hintStyle: GoogleFonts.orbitron(
                color: Colors.purpleAccent.shade100,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.purpleAccent),
              border: InputBorder.none,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistorialComprasScreen(),
                  ),
                );
              },
              child: Text(
                "HISTORIAL DE COMPRAS",
                style: GoogleFonts.orbitron(
                  color: Colors.purpleAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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

      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.purpleAccent),
              )
              : isWide
              ? Row(
                children: [
                  _buildListaBoliches(),
                  Expanded(
                    flex: 3,
                    child:
                        _seleccionado == null
                            ? Center(
                              child: Text(
                                'Selecciona un boliche 🎉',
                                style: GoogleFonts.orbitron(
                                  color: Colors.purpleAccent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            : _buildDetalle(_seleccionado!),
                  ),
                ],
              )
              : _buildListaMovil(),
    );
  }

  Widget _buildListaBoliches() {
    return Expanded(
      flex: 2,
      child: ListView(
        children:
            boliches
                .where(
                  (b) => b.nombre.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ),
                )
                .map(
                  (b) => ListTile(
                    title: Text(
                      b.nombre,
                      style: GoogleFonts.orbitron(color: Colors.white),
                    ),
                    subtitle: Text(
                      b.direccion,
                      style: GoogleFonts.orbitron(color: Colors.purpleAccent),
                    ),
                    onTap: () => _cargarDetalle(b.id),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildListaMovil() {
    return ListView(
      children:
          boliches
              .where(
                (b) => b.nombre.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
              )
              .map(
                (b) => Card(
                  color: const Color(0xFF2D014F).withOpacity(0.85),
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    title: Text(
                      b.nombre,
                      style: GoogleFonts.orbitron(color: Colors.white),
                    ),
                    subtitle: Text(
                      b.direccion,
                      style: GoogleFonts.orbitron(color: Colors.purpleAccent),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _cargarDetalle(b.id),
                      child: const Text('Ver más'),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildDetalle(DetalleBolicheDto boliche) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre y dirección
            Text(
              boliche.nombre,
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              boliche.direccion,
              style: GoogleFonts.orbitron(
                color: Colors.purpleAccent,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            // Manillas
            const Text(
              'Manillas:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...boliche.manillas.map(
              (m) => Text(
                '${m.nombre}: Bs. ${m.precio}',
                style: GoogleFonts.orbitron(color: Colors.purpleAccent),
              ),
            ),
            const SizedBox(height: 16),

            // Mesas
            const Text(
              'Mesas:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...boliche.mesas.map(
              (m) => Text(
                '${m.nombreONumero}: Bs. ${m.precioReserva}',
                style: GoogleFonts.orbitron(color: Colors.purpleAccent),
              ),
            ),
            const SizedBox(height: 20),

            // Botón Comprar
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Aquí puedes abrir la pantalla de ComprasScreen real
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ComprasScreen(
                            bolicheId: boliche.id,
                            bolicheNombre: boliche.nombre,
                          ),
                    ),
                  );
                },
                child: const Text('Comprar 🎟️'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
