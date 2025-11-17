import 'package:flutter/material.dart';
import 'package:doorpass/models/Productos/DetalleManillaTipoDto.dart';
import 'package:doorpass/models/Productos/DetalleMesaDto.dart';
import 'package:doorpass/models/Productos/DetalleComboDto.dart';

import 'package:doorpass/models/Compras/ItemManillaDto.dart';
import 'package:doorpass/models/Compras/CrearCompraManilla.dart';
import 'package:doorpass/models/Compras/ReservarMesaDto.dart';
import 'package:doorpass/models/Compras/ItemComboDto.dart';
import 'package:doorpass/models/Compras/CrearCompraCombosDto.dart';

import 'package:doorpass/services/productos_service.dart';
import 'package:doorpass/services/compras_service.dart';

class ComprasScreen extends StatefulWidget {
  final int bolicheId;
  final String bolicheNombre;

  const ComprasScreen({
    super.key,
    required this.bolicheId,
    required this.bolicheNombre,
  });

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  final ProductosService _productosService = ProductosService();
  final ComprasService _comprasService = ComprasService();

  bool loading = true;

  // Datos cargados del boliche
  List<DetalleManillaTipoDto> manillas = [];
  List<DetalleMesaDto> mesas = [];
  List<DetalleComboDto> combos = [];

  // Carritos/seleccones
  Map<int, int> carritoManillas = {};
  Map<int, bool> mesasSeleccionadas = {};
  Map<int, int> carritoCombos = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => loading = true);

    try {
      manillas = await _productosService.getManillasPorBoliche(widget.bolicheId);
    } catch (e) {
      manillas = [];
      mesas = [];
      combos = [];
    }

    // Inicializar estados
    carritoManillas = {for (var m in manillas) m.id: 0};
    mesasSeleccionadas = {for (var m in mesas) m.id: false};
    carritoCombos = {for (var c in combos) c.id: 0};

    setState(() => loading = false);
  }

  int get totalItems {
    final totalManillas = carritoManillas.values.fold(0, (p, e) => p + e);
    final totalMesas =
        mesasSeleccionadas.values.where((v) => v == true).length;
    final totalCombos = carritoCombos.values.fold(0, (p, e) => p + e);

    return totalManillas + totalMesas + totalCombos;
  }

  Future<void> _realizarCompra() async {
    setState(() => loading = true);

    // --- Manillas ---
    final manillasAComprar = carritoManillas.entries
        .where((e) => e.value > 0)
        .map(
          (e) => ItemManillaDto(
            manillaTipoId: e.key,
            cantidad: e.value,
          ),
        )
        .toList();

    if (manillasAComprar.isNotEmpty) {
      await _comprasService.comprarManillas(
        CrearCompraManillasDto(
          bolicheId: widget.bolicheId,
          manillas: manillasAComprar,
        ),
      );
    }

    // --- Mesas ---
    for (var entry in mesasSeleccionadas.entries) {
      if (entry.value) {
        await _comprasService.reservarMesa(
          ReservarMesaDto(
            bolicheId: widget.bolicheId,
            mesaId: entry.key,
          ),
        );
      }
    }

    // --- Combos ---
    final combosAComprar = carritoCombos.entries
        .where((e) => e.value > 0)
        .map(
          (e) => ItemComboDto(
            comboId: e.key,
            cantidad: e.value,
          ),
        )
        .toList();

    if (combosAComprar.isNotEmpty) {
      await _comprasService.comprarCombos(
        CrearCompraCombosDto(
          bolicheId: widget.bolicheId,
          combos: combosAComprar,
        ),
      );
    }

    // Reset
    carritoManillas.updateAll((key, value) => 0);
    mesasSeleccionadas.updateAll((key, value) => false);
    carritoCombos.updateAll((key, value) => 0);

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Compra realizada correctamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A002B),
      appBar: AppBar(
        title: Text('Compra en ${widget.bolicheNombre}'),
        backgroundColor: const Color(0xFF2D014F),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Manillas ---
                  if (manillas.isNotEmpty) ...[
                    const Text(
                      "Manillas",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...manillas.map((m) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${m.nombre} - Bs. ${m.precio}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    if (carritoManillas[m.id]! > 0) {
                                      carritoManillas[m.id] =
                                          carritoManillas[m.id]! - 1;
                                    }
                                  });
                                },
                              ),
                              Text(
                                "${carritoManillas[m.id]}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.greenAccent),
                                onPressed: () {
                                  setState(() {
                                    carritoManillas[m.id] =
                                        carritoManillas[m.id]! + 1;
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      );
                    }),
                  ],

                  const SizedBox(height: 24),

                  // --- Mesas ---
                  if (mesas.isNotEmpty) ...[
                    const Text(
                      "Mesas",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...mesas.map((mesa) {
                      return CheckboxListTile(
                        value: mesasSeleccionadas[mesa.id],
                        onChanged: (val) {
                          setState(() {
                            mesasSeleccionadas[mesa.id] = val ?? false;
                          });
                        },
                        activeColor: Colors.purpleAccent,
                        checkColor: Colors.white,
                        title: Text(
                          "${mesa.nombreONumero} - Bs. ${mesa.precioReserva}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 24),

                  // --- Combos ---
                  if (combos.isNotEmpty) ...[
                    const Text(
                      "Combos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...combos.map((c) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${c.nombre} - Bs. ${c.precio}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    if (carritoCombos[c.id]! > 0) {
                                      carritoCombos[c.id] =
                                          carritoCombos[c.id]! - 1;
                                    }
                                  });
                                },
                              ),
                              Text(
                                "${carritoCombos[c.id]}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.greenAccent),
                                onPressed: () {
                                  setState(() {
                                    carritoCombos[c.id] =
                                        carritoCombos[c.id]! + 1;
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      );
                    }),
                  ],

                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      "Total items: $totalItems",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: ElevatedButton(
                      onPressed: totalItems == 0 ? null : _realizarCompra,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                      ),
                      child: const Text(
                        "Comprar",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
