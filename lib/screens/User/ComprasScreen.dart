import 'package:flutter/material.dart';
import 'package:doorpass/models/Productos/DetalleManillaTipoDto.dart';
import 'package:doorpass/models/Productos/DetalleMesaDto.dart';
import 'package:doorpass/models/Productos/DetalleComboDto.dart';

import 'package:doorpass/models/Compras/ItemManillaDto.dart';
import 'package:doorpass/models/Compras/ItemComboDto.dart';

import 'package:doorpass/models/Compras/CrearCompraManilla.dart';
import 'package:doorpass/models/Compras/CrearCompraCombosDto.dart';
import 'package:doorpass/models/Compras/ReservarMesaDto.dart';

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

  // MANILLAS
  List<DetalleManillaTipoDto> manillas = [];
  Map<int, int> carritoManillas = {};

  // MESAS
  List<DetalleMesaDto> mesas = [];
  Map<int, bool> mesasSeleccionadas = {};

  // COMBOS
  List<DetalleComboDto> combos = [];
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
      mesas = await _productosService.getMesasPorBoliche(widget.bolicheId);
      combos = await _productosService.getCombosPorBoliche(widget.bolicheId);
    } catch (e) {
      manillas = [];
      mesas = [];
      combos = [];
    }

    carritoManillas = {for (var m in manillas) m.id: 0};
    mesasSeleccionadas = {for (var m in mesas) m.id: false};
    carritoCombos = {for (var c in combos) c.id: 0};

    setState(() => loading = false);
  }

  int get totalItems {
    final totalManillas = carritoManillas.values.fold(0, (p, c) => p + c);
    final totalMesas = mesasSeleccionadas.values.where((v) => v == true).length;
    final totalCombos = carritoCombos.values.fold(0, (p, c) => p + c);
    return totalManillas + totalMesas + totalCombos;
  }

  Future<void> _comprar() async {
    setState(() => loading = true);

    // MANILLAS
    final manillasSeleccionadas = carritoManillas.entries
        .where((e) => e.value > 0)
        .map((e) => ItemManillaDto(
              manillaTipoId: e.key,
              cantidad: e.value,
            ))
        .toList();

    if (manillasSeleccionadas.isNotEmpty) {
      await _comprasService.comprarManillas(
        CrearCompraManillasDto(
          bolicheId: widget.bolicheId,
          manillas: manillasSeleccionadas,
        ),
      );
    }

    // MESAS
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

    // COMBOS
    final combosSeleccionados = carritoCombos.entries
        .where((e) => e.value > 0)
        .map((e) => ItemComboDto(comboId: e.key, cantidad: e.value))
        .toList();

    if (combosSeleccionados.isNotEmpty) {
      await _comprasService.comprarCombos(
        CrearCompraCombosDto(
          bolicheId: widget.bolicheId,
          combos: combosSeleccionados,
        ),
      );
    }

    // Reset selección
    carritoManillas.updateAll((key, value) => 0);
    mesasSeleccionadas.updateAll((key, value) => false);
    carritoCombos.updateAll((key, value) => 0);

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra realizada con éxito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A002B),
      appBar: AppBar(
        title: Text('Compras - ${widget.bolicheNombre}'),
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
                  // ===== MANILLAS =====
                  const Text(
                    'Manillas',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(height: 10),
                  manillas.isEmpty
                      ? const Text(
                          'OUT OF STOCK',
                          style: TextStyle(color: Colors.redAccent, fontSize: 16),
                        )
                      : Column(
                          children: manillas.map((m) => _itemCantidad(
                                nombre: m.nombre,
                                precio: m.precio,
                                cantidad: carritoManillas[m.id]!,
                                onAdd: () {
                                  setState(() =>
                                      carritoManillas[m.id] = carritoManillas[m.id]! + 1);
                                },
                                onRemove: () {
                                  if (carritoManillas[m.id]! > 0) {
                                    setState(() => carritoManillas[m.id] =
                                        carritoManillas[m.id]! - 1);
                                  }
                                },
                              )).toList(),
                        ),
                  const SizedBox(height: 30),

                  // ===== MESAS =====
                  const Text(
                    'Mesas',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(height: 10),
                  mesas.isEmpty
                      ? const Text(
                          'OUT OF STOCK',
                          style: TextStyle(color: Colors.redAccent, fontSize: 16),
                        )
                      : Column(
                          children: mesas.map(
                            (mesa) => CheckboxListTile(
                              title: Text(
                                '${mesa.nombreONumero} - Bs. ${mesa.precioReserva}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              value: mesasSeleccionadas[mesa.id],
                              onChanged: (v) {
                                setState(() {
                                  mesasSeleccionadas[mesa.id] = v ?? false;
                                });
                              },
                              activeColor: Colors.purpleAccent,
                              checkColor: Colors.white,
                            ),
                          ).toList(),
                        ),
                  const SizedBox(height: 30),

                  // ===== COMBOS =====
                  const Text(
                    'Combos',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(height: 10),
                  combos.isEmpty
                      ? const Text(
                          'OUT OF STOCK',
                          style: TextStyle(color: Colors.redAccent, fontSize: 16),
                        )
                      : Column(
                          children: combos.map((c) => _comboCard(c)).toList(),
                        ),

                  const SizedBox(height: 40),

                  Text(
                    'Total Ítems: $totalItems',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 15),

                  Center(
                    child: ElevatedButton(
                      onPressed: totalItems == 0 ? null : _comprar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 70, vertical: 18),
                      ),
                      child: const Text(
                        'Comprar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ====== Widgets Reutilizables ======
  Widget _itemCantidad({
    required String nombre,
    required double precio,
    required int cantidad,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$nombre - Bs. $precio',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.redAccent),
                onPressed: onRemove,
              ),
              Text(
                '$cantidad',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.greenAccent),
                onPressed: onAdd,
              ),
            ],
          )
        ],
      ),
    );
  }

  // ====== Widget para combos estético ======
  Widget _comboCard(DetalleComboDto c) {
    return Card(
      color: const Color(0xFF2D014F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            if (c.imagenUrl != null && c.imagenUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  c.imagenUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.white70),
                  ),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.white70),
              ),
            const SizedBox(width: 12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.nombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  if (c.descripcion != null && c.descripcion!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        c.descripcion!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    'Bs. ${c.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Cantidad
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                  onPressed: () {
                    if (carritoCombos[c.id]! > 0) {
                      setState(() =>
                          carritoCombos[c.id] = carritoCombos[c.id]! - 1);
                    }
                  },
                ),
                Text(
                  '${carritoCombos[c.id]}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.add_circle, color: Colors.greenAccent),
                  onPressed: () {
                    setState(() =>
                        carritoCombos[c.id] = carritoCombos[c.id]! + 1);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
