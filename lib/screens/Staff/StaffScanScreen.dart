import 'package:flutter/material.dart';

class StaffScanScreen extends StatefulWidget {
  const StaffScanScreen({super.key});

  @override
  State<StaffScanScreen> createState() => _StaffScanScreenState();
}

class _StaffScanScreenState extends State<StaffScanScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final List<Map<String, String>> _data = [
    {'nombre': 'Juan Pérez', 'ticket': 'VIP001'},
    {'nombre': 'Ana Gómez', 'ticket': 'SUPERVIP002'},
    {'nombre': 'Carlos Díaz', 'ticket': 'MESA003'},
    {'nombre': 'Lucía Morales', 'ticket': 'VIP004'},
  ];
  List<Map<String, String>> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(_data);
  }

  void _filterData(String query) {
    final filtered =
        _data
            .where(
              (item) =>
                  item['nombre']!.toLowerCase().contains(query.toLowerCase()) ||
                  item['ticket']!.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    setState(() {
      _filteredData = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1A002B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D014F),
        title: const Text("Scanear / Buscar"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
          width: isWide ? 600 : double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2D014F).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            children: [
              // BARRA DE BÚSQUEDA
              TextField(
                controller: _searchCtrl,
                onChanged: _filterData,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Buscar usuario o ticket...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.purpleAccent,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purpleAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF3D0050),
                ),
              ),
              const SizedBox(height: 24),

              // LISTA DE RESULTADOS
              Expanded(
                child:
                    _filteredData.isEmpty
                        ? const Center(
                          child: Text(
                            "No se encontraron resultados",
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                        : ListView.builder(
                          itemCount: _filteredData.length,
                          itemBuilder: (context, index) {
                            final item = _filteredData[index];
                            return Card(
                              color: const Color(0xFF1A0026),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  item['nombre']!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  item['ticket']!,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    // Aquí puedes añadir acción de escanear/validar
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purpleAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Validar"),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
