import 'package:flutter/material.dart';

class ComprasScreen extends StatefulWidget {
  final String bolicheNombre;
  final String imagenUrl;

  const ComprasScreen({
    super.key,
    required this.bolicheNombre,
    required this.imagenUrl,
  });

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  // Cantidad de manillas
  final Map<String, int> carrito = {'VIP': 0, 'Super VIP': 0, 'Mesa': 0};

  // Lista para manejar mesas individuales
  List<int?> mesasSeleccionadas = [];

  // Combos disponibles
  final Map<String, int> combos = {
    'Combo 1: 3 Cervezas': 0,
    'Combo 2: 1 Vodka + 2 Red Bull': 0,
    'Combo 3: Pack Shots': 0,
  };

  final List<int> _mesas = List.generate(20, (index) => index + 1);

  int get totalItems {
    int manillas = carrito.values.fold(0, (p, e) => p + e);
    int totalCombos = combos.values.fold(0, (p, e) => p + e);
    return manillas + totalCombos;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1A002B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D014F),
        title: Text('Compra en ${widget.bolicheNombre}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: isWide ? 500 : double.infinity,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // IMAGEN DEL BOLICHE
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.imagenUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // MANILLAS
                const Text(
                  'Selecciona Manillas',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 8),
                ...carrito.keys.map((tipo) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tipo,
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
                                  if (carrito[tipo]! > 0) {
                                    carrito[tipo] = carrito[tipo]! - 1;
                                    if (tipo == 'Mesa' &&
                                        mesasSeleccionadas.isNotEmpty) {
                                      mesasSeleccionadas.removeLast();
                                    }
                                  }
                                });
                              },
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.redAccent,
                              ),
                            ),
                            Text(
                              '${carrito[tipo]}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  carrito[tipo] = carrito[tipo]! + 1;
                                  if (tipo == 'Mesa') {
                                    mesasSeleccionadas.add(null);
                                  }
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
                    ),
                  );
                }).toList(),

                // MESAS INDIVIDUALES
                if (carrito['Mesa']! > 0)
                  Column(
                    children: List.generate(carrito['Mesa']!, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: DropdownButtonFormField<int>(
                          value: mesasSeleccionadas[index],
                          items:
                              _mesas
                                  .map(
                                    (mesa) => DropdownMenuItem(
                                      value: mesa,
                                      child: Text('Mesa $mesa'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            setState(() {
                              mesasSeleccionadas[index] = val;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Mesa ${index + 1}',
                            labelStyle: const TextStyle(
                              color: Colors.purpleAccent,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.purpleAccent,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blueAccent,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF3D0050),
                          ),
                          dropdownColor: const Color(0xFF2D014F),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }),
                  ),

                const SizedBox(height: 24),

                // COMBOS
                const Text(
                  'Selecciona Combos',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 8),
                ...combos.keys.map((combo) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          combo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (combos[combo]! > 0)
                                    combos[combo] = combos[combo]! - 1;
                                });
                              },
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.redAccent,
                              ),
                            ),
                            Text(
                              '${combos[combo]}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  combos[combo] = combos[combo]! + 1;
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
                    ),
                  );
                }).toList(),

                const SizedBox(height: 32),

                // RESUMEN
                Text(
                  'Total Items: $totalItems',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),

                // BOTÓN COMPRAR
                ElevatedButton(
                  onPressed:
                      totalItems == 0
                          ? null
                          : () {
                            String resumen = '';

                            carrito.forEach((tipo, cantidad) {
                              if (cantidad > 0) {
                                if (tipo == 'Mesa') {
                                  for (
                                    int i = 0;
                                    i < mesasSeleccionadas.length;
                                    i++
                                  ) {
                                    resumen +=
                                        'Mesa ${mesasSeleccionadas[i] ?? "-"}\n';
                                  }
                                } else {
                                  resumen += '$cantidad $tipo\n';
                                }
                              }
                            });

                            combos.forEach((combo, cantidad) {
                              if (cantidad > 0) {
                                resumen += '$cantidad x $combo\n';
                              }
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Compra realizada:\n$resumen'),
                              ),
                            );
                          },
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
                    shadowColor: Colors.purpleAccent.withOpacity(0.6),
                    elevation: 10,
                  ),
                  child: const Text('Comprar', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
