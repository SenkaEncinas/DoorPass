import 'package:flutter/material.dart';
import 'package:doorpass/models/Productos/DetalleManillaTipoDto.dart';
import 'package:doorpass/models/Productos/DetalleMesaDto.dart';
import 'package:doorpass/models/Compras/ItemManillaDto.dart';
import 'package:doorpass/models/Compras/CrearCompraManilla.dart';
import 'package:doorpass/models/Compras/ReservarMesaDto.dart';
import 'package:doorpass/services/admin_service.dart';
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
  final AdminService _adminService = AdminService();
  final ComprasService _comprasService = ComprasService();

  bool loading = true;

  List<DetalleManillaTipoDto> manillas = [];
  Map<int, int> carritoManillas = {};

  List<DetalleMesaDto> mesas = [];
  Map<int, bool> mesasSeleccionadas = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => loading = true);

    // Traer manillas y mesas desde AdminService
    manillas = await _adminService.getManillas(widget.bolicheId);
    mesas = await _adminService.getMesas(widget.bolicheId);

    // Inicializar carrito y mesas seleccionadas
    carritoManillas = {for (var m in manillas) m.id: 0};
    mesasSeleccionadas = {for (var m in mesas) m.id: false};

    setState(() => loading = false);
  }

  int get totalItems {
    int totalManillas = carritoManillas.values.fold(0, (p, e) => p + e);
    int totalMesas = mesasSeleccionadas.values.where((v) => v).length;
    return totalManillas + totalMesas;
  }

  Future<void> _comprar() async {
    setState(() => loading = true);

    // Crear lista de manillas seleccionadas
    final List<ItemManillaDto> manillasSeleccionadas = [];
    carritoManillas.forEach((id, cantidad) {
      if (cantidad > 0) {
        manillasSeleccionadas.add(
          ItemManillaDto(manillaTipoId: id, cantidad: cantidad),
        );
      }
    });

    // Comprar manillas
    if (manillasSeleccionadas.isNotEmpty) {
      await _comprasService.comprarManillas(
        CrearCompraManillasDto(
          bolicheId: widget.bolicheId,
          manillas: manillasSeleccionadas,
        ),
      );
    }

    // Reservar mesas
    for (var entry in mesasSeleccionadas.entries) {
      if (entry.value) {
        await _comprasService.reservarMesa(
          ReservarMesaDto(bolicheId: widget.bolicheId, mesaId: entry.key),
        );
      }
    }

    setState(() => loading = false);

    // Reiniciar selección
    carritoManillas.updateAll((key, value) => 0);
    mesasSeleccionadas.updateAll((key, value) => false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra realizada correctamente')),
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
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.purpleAccent),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Manillas
                    const Text(
                      'Selecciona Manillas',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    ...manillas.map((m) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${m.nombre} - Bs. ${m.precio}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (carritoManillas[m.id]! > 0)
                                      carritoManillas[m.id] =
                                          carritoManillas[m.id]! - 1;
                                  });
                                },
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.redAccent,
                                ),
                              ),
                              Text(
                                '${carritoManillas[m.id]}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    carritoManillas[m.id] =
                                        carritoManillas[m.id]! + 1;
                                  });
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }).toList(),

                    const SizedBox(height: 24),

                    // Mesas
                    if (mesas.isNotEmpty) ...[
                      const Text(
                        'Selecciona Mesas',
                        style: TextStyle(color: Colors.white, fontSize: 20),
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
                          title: Text(
                            '${mesa.nombreONumero} - Bs. ${mesa.precioReserva}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          activeColor: Colors.purpleAccent,
                          checkColor: Colors.white,
                        );
                      }),
                    ],

                    const SizedBox(height: 32),
                    Text(
                      'Total Items: $totalItems',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Botón Comprar
                    ElevatedButton(
                      onPressed: totalItems == 0 ? null : _comprar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Comprar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
