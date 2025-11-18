import 'package:doorpass/models/Productos/DetalleBolicheDto.dart';
import 'package:doorpass/models/Productos/DetalleBolichesSimpleDto.dart';
import 'package:doorpass/screens/LoginScreen.dart';
import 'package:doorpass/screens/User/ComprasScreen.dart';
import 'package:doorpass/services/productos_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void _seleccionarBoliche(DetalleBolicheSimpleDto bolicheSimple, bool isWide) async {
    final detalle = await _productsService.getBolicheDetalle(bolicheSimple.id);
    if (detalle == null) return;

    if (isWide) {
      setState(() => _seleccionado = detalle);
    } else {
      _mostrarDetalleModal(detalle);
    }
  }

  void _mostrarDetalleModal(DetalleBolicheDto detalle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF100018),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: _detalleContenido(detalle),
        ),
      ),
    );
  }

  Widget _detalleContenido(DetalleBolicheDto detalle) {
    final textStyleTitulo = GoogleFonts.orbitron(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
    final textStyleNormal = GoogleFonts.orbitron(color: Colors.purpleAccent);
    final textStyleNombre = GoogleFonts.orbitron(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold);

    return Column(
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
        Text(detalle.nombre, style: textStyleNombre),
        const SizedBox(height: 8),
        Text(detalle.direccion ?? '', style: textStyleNormal),
        const SizedBox(height: 16),

        if (detalle.manillas.isNotEmpty) ...[
          Text('Manillas:', style: textStyleTitulo),
          const SizedBox(height: 6),
          ...detalle.manillas.map((m) => Text('${m.nombre}: Bs. ${m.precio}', style: textStyleNormal)),
          const SizedBox(height: 16),
        ],

        if (detalle.mesas.isNotEmpty) ...[
          Text('Mesas:', style: textStyleTitulo),
          const SizedBox(height: 6),
          ...detalle.mesas.map((m) => Text('${m.nombreONumero}: Bs. ${m.precioReserva}', style: textStyleNormal)),
          const SizedBox(height: 16),
        ],

        if (detalle.combos.isNotEmpty) ...[
          Text('Combos:', style: textStyleTitulo),
          const SizedBox(height: 6),
          ...detalle.combos.map(
            (c) => Card(
              color: const Color(0xFF3A0055),
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.nombre, style: textStyleNombre.copyWith(fontSize: 18)),
                    if (c.descripcion != null && c.descripcion!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(c.descripcion!, style: textStyleNormal.copyWith(color: Colors.white70, fontStyle: FontStyle.italic)),
                      ),
                    Text('Precio: Bs. ${c.precio}', style: textStyleNormal),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComprasScreen(bolicheId: detalle.id, bolicheNombre: detalle.nombre),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                child: Text('Comprar 🎟️', style: textStyleNombre.copyWith(fontSize: 18)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
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
              colors: [const Color(0xFF7C4DFF).withOpacity(0.6), const Color(0xFFE040FB).withOpacity(0.6)],
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
              hintStyle: GoogleFonts.orbitron(color: Colors.purpleAccent.shade100),
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistorialComprasScreen()));
              },
              child: Text("HISTORIAL DE COMPRAS", style: GoogleFonts.orbitron(color: Colors.purpleAccent, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
          : isWide
              ? Row(
                  children: [
                    _buildListaBoliches(isWide),
                    Expanded(
                      flex: 3,
                      child: _seleccionado == null
                          ? Center(child: Text('Selecciona un boliche 🎉', style: GoogleFonts.orbitron(color: Colors.purpleAccent, fontSize: 22, fontWeight: FontWeight.bold)))
                          : SingleChildScrollView(padding: const EdgeInsets.all(16), child: _detalleContenido(_seleccionado!)),
                    ),
                  ],
                )
              : _buildListaBoliches(isWide),
    );
  }

  Widget _buildListaBoliches(bool isWide) {
    return Expanded(
      flex: 2,
      child: ListView.builder(
        itemCount: boliches.length,
        itemBuilder: (_, index) {
          final b = boliches[index];
          if (!b.nombre.toLowerCase().contains(_searchController.text.toLowerCase())) return const SizedBox.shrink();

          return Card(
            color: const Color(0xFF2D014F).withOpacity(0.85),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              title: Text(b.nombre, style: GoogleFonts.orbitron(color: Colors.white)),
              subtitle: Text(b.direccion, style: GoogleFonts.orbitron(color: Colors.purpleAccent)),
              trailing: isWide
                  ? null
                  : Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _seleccionarBoliche(b, isWide),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Text('Ver más', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
              onTap: () => _seleccionarBoliche(b, isWide),
            ),
          );
        },
      ),
    );
  }
}
