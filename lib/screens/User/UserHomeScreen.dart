import 'package:doorpass/screens/User/ComprasScreen.dart';
import 'package:doorpass/screens/User/HistorialComprasScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> boliches = [
    {
      'nombre': 'Neon Club',
      'precio': 80,
      'imagen':
          'https://images.unsplash.com/photo-1604079628040-94301bb21b93?auto=format&fit=crop&w=500&q=80',
      'descripcion': 'Ambiente neón con DJs internacionales y área VIP.',
      'vip': {'Normal': 80, 'VIP': 150, 'Super VIP': 250, 'Mesa': 400},
    },
    {
      'nombre': 'Purple Night',
      'precio': 100,
      'imagen':
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=500&q=80',
      'descripcion': 'Una noche mágica llena de luces y música electrónica.',
      'vip': {'Normal': 100, 'VIP': 180, 'Super VIP': 300, 'Mesa': 450},
    },
    {
      'nombre': 'Galaxy Bar',
      'precio': 70,
      'imagen':
          'https://images.unsplash.com/photo-1532635249-17e820acc59f?auto=format&fit=crop&w=500&q=80',
      'descripcion': 'Ambiente galáctico con cocteles brillantes.',
      'vip': {'Normal': 70, 'VIP': 120, 'Super VIP': 200, 'Mesa': 350},
    },
  ];

  Map<String, dynamic>? _seleccionado;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFF100018),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D014F),
        elevation: 8,
        shadowColor: Colors.purpleAccent.withOpacity(0.6),

        // 🔹 Campo de búsqueda al centro
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

        // 🔹 Botón HISTORIAL DE COMPRAS
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
              style: TextButton.styleFrom(foregroundColor: Colors.purpleAccent),
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
        ],
      ),

      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF12002B), Color(0xFF2B0055), Color(0xFF12002B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            isWide
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
      ),
    );
  }

  // 🌆 Lista lateral (desktop)
  Widget _buildListaBoliches() {
    return Expanded(
      flex: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2D014F).withOpacity(0.5),
              const Color(0xFF100018),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children:
              boliches
                  .where(
                    (b) => b['nombre'].toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ),
                  )
                  .map(
                    (b) => Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3A0066).withOpacity(0.8),
                            const Color(0xFF1A002B).withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.network(
                              b['imagen'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          b['nombre'],
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '\$${b['precio']}',
                          style: GoogleFonts.orbitron(
                            color: Colors.purpleAccent,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () => setState(() => _seleccionado = b),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  // 📱 Lista móvil
  Widget _buildListaMovil() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children:
          boliches
              .where(
                (b) => b['nombre'].toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
              )
              .map(
                (b) => Card(
                  color: const Color(0xFF2D014F).withOpacity(0.85),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  shadowColor: Colors.purpleAccent.withOpacity(0.6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // imagen
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: Image.network(b['imagen'], fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b['nombre'],
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              b['descripcion'],
                              style: GoogleFonts.orbitron(
                                color: Colors.purpleAccent,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: ElevatedButton(
                                onPressed: () => _mostrarDetallesCelular(b),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purpleAccent,
                                  foregroundColor: Colors.black,
                                  shadowColor: Colors.purpleAccent,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text('Ver más'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  // 💎 Detalle (desktop)
  Widget _buildDetalle(Map<String, dynamic> boliche) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF24004F), Color(0xFF100018)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              boliche['nombre'],
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: Image.network(boliche['imagen'], fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              boliche['descripcion'],
              style: GoogleFonts.orbitron(
                color: Colors.purpleAccent.shade100,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.purpleAccent),
            const Text(
              'Precios:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...boliche['vip'].entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${e.key}: \$${e.value}',
                  style: GoogleFonts.orbitron(
                    color: Colors.purpleAccent,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ComprasScreen(
                            bolicheNombre: boliche['nombre'],
                            imagenUrl: boliche['imagen'],
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.black,
                  shadowColor: Colors.purpleAccent,
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Comprar 🎟️',
                  style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetallesCelular(Map<String, dynamic> boliche) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF2D014F),
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: _buildDetalle(boliche),
          ),
    );
  }
}
