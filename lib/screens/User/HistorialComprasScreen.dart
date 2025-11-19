import 'package:flutter/material.dart';
import 'package:doorpass/services/compras_service.dart';
import 'package:doorpass/models/Compras/DetalleCompraDto.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

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

  // NUEVA FUNCIÓN: cancelar compra
  Future<void> _cancelarCompra(DetalleCompraDto compra) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A002B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancelar compra',
          style: GoogleFonts.orbitron(color: Colors.white),
        ),
        content: Text(
          '¿Seguro que quieres cancelar la compra #${compra.compraId}?',
          style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No',
              style: GoogleFonts.orbitron(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sí, cancelar',
              style: GoogleFonts.orbitron(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final exito = await _service.cancelarCompra(compra.compraId);

    if (!mounted) return;

    if (exito) {
      // recargamos el historial para que se vea como cancelada
      setState(() {
        _futureHistorial = _service.getMiHistorial();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Compra #${compra.compraId} cancelada con éxito',
            style: GoogleFonts.orbitron(),
          ),
          backgroundColor: Colors.greenAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo cancelar la compra #${compra.compraId}',
            style: GoogleFonts.orbitron(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _mostrarDetalleCompra(DetalleCompraDto compra) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: const Color(0xFF1A002B),
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// ---------------------------
                  ///        QR CON LA ID
                  /// ---------------------------
                  Center(
                    child: QrImageView(
                      data: _generarJsonCompra(compra),
                      size: 200,
                      backgroundColor: Colors.white, // Hace que se vea mejor
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Compra #${compra.compraId}",
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// RESTO DE TU CONTENIDO ORIGINAL
                  Text(
                    compra.nombreBoliche,
                    style: GoogleFonts.orbitron(
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Fecha: ${compra.fechaCompra.toLocal()}",
                    style: GoogleFonts.orbitron(
                      color: Colors.white54,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Tipo de Compra: ${compra.tipoCompra}",
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (compra.manillasCompradas.isNotEmpty) ...[
                    Text(
                      "Manillas Compradas:",
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...compra.manillasCompradas.map(
                      (m) => Text(
                        "- ${m.nombreManilla} x${m.cantidad}",
                        style: GoogleFonts.orbitron(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (compra.combosComprados.isNotEmpty) ...[
                    Text(
                      "Combos Comprados:",
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...compra.combosComprados.map(
                      (c) => Text(
                        "- ${c.nombreCombo} x${c.cantidad}",
                        style: GoogleFonts.orbitron(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (compra.mesaReservada != null)
                    Text(
                      "Mesa Reservada: ${compra.mesaReservada}",
                      style: GoogleFonts.orbitron(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                  const SizedBox(height: 12),

                  Text(
                    "Total Pagado: Bs ${compra.totalPagado.toStringAsFixed(2)}",
                    style: GoogleFonts.orbitron(
                      color: Colors.greenAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        compra.estaActiva ? Icons.check_circle : Icons.cancel,
                        color:
                            compra.estaActiva
                                ? Colors.lightBlueAccent
                                : Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        compra.estaActiva ? "Activa" : "Cancelada",
                        style: GoogleFonts.orbitron(
                          color:
                              compra.estaActiva
                                  ? Colors.lightBlueAccent
                                  : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                        ),
                        child: Text("Cerrar", style: GoogleFonts.orbitron()),
                      ),
                      const SizedBox(width: 12),
                      if (compra.estaActiva)
                        ElevatedButton(
                          onPressed: () {
                            // cierro el diálogo de detalle
                            Navigator.pop(context);
                            // y luego ejecuto la cancelación
                            _cancelarCompra(compra);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: Text(
                            "Cancelar compra",
                            style: GoogleFonts.orbitron(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  String _generarJsonCompra(DetalleCompraDto compra) {
    final data = {
      "id": compra.compraId,
      "boliche": compra.nombreBoliche,
      "fecha": compra.fechaCompra.toIso8601String(),
      "tipoCompra": compra.tipoCompra,
      "manillas":
          compra.manillasCompradas
              .map((m) => {"nombre": m.nombreManilla, "cantidad": m.cantidad})
              .toList(),
      "combos":
          compra.combosComprados
              .map((c) => {"nombre": c.nombreCombo, "cantidad": c.cantidad})
              .toList(),
      "mesa": compra.mesaReservada,
      "total": compra.totalPagado,
      "estado": compra.estaActiva ? "Activa" : "Cancelada",
    };

    return jsonEncode(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100018),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D014F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Historial de Compras",
          style: GoogleFonts.orbitron(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<List<DetalleCompraDto>>(
        future: _futureHistorial,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final compras = snapshot.data!;

          if (compras.isEmpty) {
            return Center(
              child: Text(
                "No tienes compras aún ✨",
                style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: compras.length,
            itemBuilder: (context, index) {
              final compra = compras[index];
              final gradientColors =
                  compra.estaActiva
                      ? [const Color(0xFF2D014F), const Color(0xFF3D025F)]
                      : [
                        Colors.redAccent.withOpacity(0.7),
                        Colors.redAccent.withOpacity(0.4),
                      ];
              final textColor =
                  compra.estaActiva ? Colors.white : Colors.red[900];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () => _mostrarDetalleCompra(compra),
                  title: Text(
                    "Compra #${compra.compraId}",
                    style: GoogleFonts.orbitron(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        compra.nombreBoliche,
                        style: GoogleFonts.orbitron(
                          color: textColor?.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Total: Bs ${compra.totalPagado.toStringAsFixed(2)}",
                        style: GoogleFonts.orbitron(
                          color:
                              compra.estaActiva
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing:
                      compra.estaActiva
                          ? QrImageView(
                            data: _generarJsonCompra(compra),
                            size: 70,
                            backgroundColor: Colors.white,
                          )
                          : Icon(
                            Icons.cancel,
                            color: Colors.redAccent,
                            size: 28,
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
  
