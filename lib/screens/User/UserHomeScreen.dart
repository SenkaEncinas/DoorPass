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
  final ProductosService _productsService = ProductosService();

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

  // Función para mostrar detalle completo en modal
  void _mostrarDetalleModal(DetalleBolicheSimpleDto bolicheSimple) async {
    final detalle = await _productsService.getBolicheDetalle(bolicheSimple.id);
    if (detalle == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF100018),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (detalle.imagenUrl != null && detalle.imagenUrl!.isNotEmpty)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          detalle.imagenUrl!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    detalle.nombre,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detalle.direccion ?? '',
                    style: GoogleFonts.orbitron(
                      color: Colors.purpleAccent,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Manillas
                  if (detalle.manillas.isNotEmpty) ...[
                    const Text(
                      'Manillas:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    ...detalle.manillas.map(
                      (m) => Text(
                        '${m.nombre}: Bs. ${m.precio}',
                        style: GoogleFonts.orbitron(color: Colors.purpleAccent),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Mesas
                  if (detalle.mesas.isNotEmpty) ...[
                    const Text(
                      'Mesas:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    ...detalle.mesas.map(
                      (m) => Text(
                        '${m.nombreONumero}: Bs. ${m.precioReserva}',
                        style: GoogleFonts.orbitron(color: Colors.purpleAccent),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Combos
                  if (detalle.combos.isNotEmpty) ...[
                    const Text(
                      'Combos:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    ...detalle.combos.map(
                      (c) => Card(
                        color: const Color(0xFF3A0055),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.nombre,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (c.descripcion != null && c.descripcion!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    c.descripcion!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              Text(
                                'Precio: Bs. ${c.precio}',
                                style: const TextStyle(color: Colors.purpleAccent),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ComprasScreen(
                              bolicheId: detalle.id,
                              bolicheNombre: detalle.nombre,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                      ),
                      child: const Text('Comprar 🎟️'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
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
                    builder: (_) => const HistorialComprasScreen(),
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
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            )
          : isWide
              ? Row(
                  children: [
                    _buildListaBoliches(),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          'Selecciona un boliche 🎉',
                          style: GoogleFonts.orbitron(
                            color: Colors.purpleAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _buildListaMovil(),
    );
  }

  Widget _buildListaBoliches() {
    return Expanded(
      flex: 2,
      child: ListView.builder(
        itemCount: boliches.length,
        itemBuilder: (_, index) {
          final b = boliches[index];
          if (!b.nombre.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ))
            return const SizedBox.shrink();
          return ListTile(
            title: Text(
              b.nombre,
              style: GoogleFonts.orbitron(color: Colors.white),
            ),
            subtitle: Text(
              b.direccion,
              style: GoogleFonts.orbitron(color: Colors.purpleAccent),
            ),
            onTap: () => _mostrarDetalleModal(b),
          );
        },
      ),
    );
  }

  Widget _buildListaMovil() {
    return ListView.builder(
      itemCount: boliches.length,
      itemBuilder: (_, index) {
        final b = boliches[index];
        if (!b.nombre.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        ))
          return const SizedBox.shrink();
        return Card(
          color: const Color(0xFF2D014F).withOpacity(0.85),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
              onPressed: () => _mostrarDetalleModal(b),
              child: const Text('Ver más'),
            ),
          ),
        );
      },
    );
  }
}
