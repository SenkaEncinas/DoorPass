import 'package:doorpass/services/compras_service.dart';
import 'package:flutter/material.dart';
import 'package:doorpass/models/Compras/DetalleCompraDto.dart';

class HistorialComprasScreen extends StatefulWidget {
  const HistorialComprasScreen({super.key});

  @override
  State<HistorialComprasScreen> createState() => _HistorialComprasScreenState();
}

class _HistorialComprasScreenState extends State<HistorialComprasScreen> {
  final ComprasService _service = ComprasService();
  late Future<List<DetalleCompraDto>> _futureHistorial;

  @override
  void initState() {
    super.initState();
    _futureHistorial = _service.getMiHistorial();
  }

  void _mostrarDetalleCompra(DetalleCompraDto compra) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A002B),
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Compra #${compra.compraId}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                compra.nombreBoliche,
                style: const TextStyle(color: Colors.white70, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                "Fecha: ${compra.fechaCompra.toLocal()}",
                style: const TextStyle(color: Colors.white54, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text(
                "Tipo de Compra: ${compra.tipoCompra}",
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (compra.manillasCompradas.isNotEmpty) ...[
                const Text(
                  "Manillas Compradas:",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...compra.manillasCompradas.map(
                  (m) => Text(
                    "- ${m.nombreManilla} x${m.cantidad}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (compra.combosComprados.isNotEmpty) ...[
                const Text(
                  "Combos Comprados:",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...compra.combosComprados.map(
                  (c) => Text(
                    "- ${c.nombreCombo} x${c.cantidad}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (compra.mesaReservada != null)
                Text(
                  "Mesa Reservada: ${compra.mesaReservada}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              const SizedBox(height: 12),
              Text(
                "Total Pagado: Bs ${compra.totalPagado.toStringAsFixed(2)}",
                style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                compra.estaActiva ? "Estado: Activa" : "Estado: Cancelada",
                style: TextStyle(
                    color: compra.estaActiva ? Colors.lightBlueAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
                  child: const Text("Cerrar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100018),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D014F),
        title: const Text("Historial de Compras"),
      ),
      body: FutureBuilder<List<DetalleCompraDto>>(
        future: _futureHistorial,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }

          final compras = snapshot.data!;

          if (compras.isEmpty) {
            return const Center(
              child: Text(
                "No tienes compras aún ✨",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: compras.length,
            itemBuilder: (context, index) {
              final compra = compras[index];
              return Card(
                color: const Color(0xFF2D014F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _mostrarDetalleCompra(compra),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Compra #${compra.compraId}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          compra.nombreBoliche,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          "Total: Bs ${compra.totalPagado.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.greenAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
