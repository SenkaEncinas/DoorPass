import 'package:doorpass/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:doorpass/services/staff_service.dart';
import 'package:doorpass/models/Compras/DetalleCompraDto.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final StaffService _staffService = StaffService();
  List<DetalleCompraDto> historial = [];
  bool loading = true;
  List<bool> expanded = [];

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  Future<void> cargarHistorial() async {
    final data = await _staff_service_getSafely();
    setState(() {
      historial = data;
      expanded = List.generate(data.length, (_) => false);
      loading = false;
    });
  }

  // Llamada segura para evitar crash si el servicio falla
  Future<List<DetalleCompraDto>> _staff_service_getSafely() async {
    try {
      return await _staffService.getHistorialCompras();
    } catch (e) {
      // En caso de error retorna lista vacía y no crashea la UI
      debugPrint('Error cargando historial: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0014),
appBar: AppBar(
  title: const Text(
    "Panel de Staff",
    style: TextStyle(color: Colors.white),
  ),
  backgroundColor: const Color(0xFF6A0DAD),
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      onPressed: () {
        Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
      },
      tooltip: 'Cerrar sesión',
    ),
  ],
),


      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.purpleAccent),
              )
              : historial.isEmpty
              ? const Center(
                child: Text(
                  "No hay historial de compras",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historial.length,
                itemBuilder: (context, index) {
                  final compra = historial[index];
                  final isOpen = expanded[index];

                  return Card(
                    color: const Color(0xFF1A0026),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        ListTile(
                          textColor: Colors.white,
                          title: Text(
                            "Compra #${compra.compraId}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            "Comprador: ${compra.nombreUsuario}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Icon(
                            isOpen ? Icons.expand_less : Icons.expand_more,
                            color: Colors.white,
                          ),
                          onTap: () {
                            setState(() {
                              expanded[index] = !expanded[index];
                            });
                          },
                        ),

                        if (isOpen)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _linea("Boliche:", compra.nombreBoliche),
                                _linea("Tipo de compra:", compra.tipoCompra),
                                _linea(
                                  "Fecha:",
                                  compra.fechaCompra
                                      .toLocal()
                                      .toString()
                                      .replaceFirst('T', ' '),
                                ),
                                _linea(
                                  "Total:",
                                  "Bs. ${compra.totalPagado.toStringAsFixed(2)}",
                                ),
                                const SizedBox(height: 10),
                                _linea(
                                  "Mesa reservada:",
                                  compra.mesaReservada ?? "Ninguna",
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Manillas compradas:",
                                  style: TextStyle(
                                    color: Colors.purpleAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Aquí usamos los campos reales del DTO: nombreManilla, cantidad, precioPagado
                                if (compra.manillasCompradas.isNotEmpty)
                                  ...compra.manillasCompradas.map((m) {
                                    final precio =
                                        (m.precioPagado ?? 0).toDouble();
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Text(
                                        "- ${m.nombreManilla} (x${m.cantidad}) — Bs. ${precio.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    );
                                  }).toList()
                                else
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      "No hay manillas registradas",
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget _linea(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "$titulo $valor",
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
