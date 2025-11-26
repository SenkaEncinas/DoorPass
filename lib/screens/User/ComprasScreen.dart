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
import 'package:google_fonts/google_fonts.dart';

// CONSTANTES
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_gradients.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_radius.dart';
import 'package:doorpass/screens/constants/app_shadows.dart';

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

  List<DetalleManillaTipoDto> manillas = [];
  Map<int, int> carritoManillas = {};
  List<DetalleMesaDto> mesas = [];
  Map<int, bool> mesasSeleccionadas = {};
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
      manillas = await _productosService.getManillasPorBoliche(
        widget.bolicheId,
      );
      mesas = await _productosService.getMesasPorBoliche(widget.bolicheId);
      combos = await _productosService.getCombosPorBoliche(widget.bolicheId);
    } catch (_) {
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
    final totalMesas = mesasSeleccionadas.values.where((v) => v).length;
    final totalCombos = carritoCombos.values.fold(0, (p, c) => p + c);
    return totalManillas + totalMesas + totalCombos;
  }

  Future<void> _comprar() async {
    setState(() => loading = true);

    final manillasSeleccionadas =
        carritoManillas.entries
            .where((e) => e.value > 0)
            .map((e) => ItemManillaDto(manillaTipoId: e.key, cantidad: e.value))
            .toList();

    if (manillasSeleccionadas.isNotEmpty) {
      await _comprasService.comprarManillas(
        CrearCompraManillasDto(
          bolicheId: widget.bolicheId,
          manillas: manillasSeleccionadas,
        ),
      );
    }

    for (var entry in mesasSeleccionadas.entries) {
      if (entry.value) {
        await _comprasService.reservarMesa(
          ReservarMesaDto(bolicheId: widget.bolicheId, mesaId: entry.key),
        );
      }
    }

    final combosSeleccionados =
        carritoCombos.entries
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

    carritoManillas.updateAll((key, value) => 0);
    mesasSeleccionadas.updateAll((key, value) => false);
    carritoCombos.updateAll((key, value) => 0);

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryAccent,
        content: Text(
          'Compra realizada con éxito',
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        centerTitle: true,
        elevation: 4,
        shadowColor: AppColors.primaryAccent.withOpacity(0.4),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Compras - ${widget.bolicheNombre}',
          style: AppTextStyles.titleSection.copyWith(
            color: AppColors.textSecondary,
            fontSize: 18,
          ),
        ),
      ),
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.progress),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _seccionTitulo('Manillas'),
                    manillas.isEmpty
                        ? _outOfStock()
                        : Column(
                          children:
                              manillas
                                  .map(
                                    (m) => _itemCantidad(
                                      nombre: m.nombre,
                                      precio: m.precio,
                                      cantidad: carritoManillas[m.id]!,
                                      onAdd:
                                          () => setState(
                                            () => carritoManillas[m.id] =
                                                carritoManillas[m.id]! + 1,
                                          ),
                                      onRemove: () {
                                        if (carritoManillas[m.id]! > 0) {
                                          setState(
                                            () => carritoManillas[m.id] =
                                                carritoManillas[m.id]! - 1,
                                          );
                                        }
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                    const SizedBox(height: AppSpacing.xxl),

                    _seccionTitulo('Mesas'),
                    mesas.isEmpty
                        ? _outOfStock()
                        : Column(
                          children:
                              mesas
                                  .map(
                                    (mesa) => Container(
                                      margin:
                                          const EdgeInsets.symmetric(
                                            vertical: AppSpacing.xs,
                                          ),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.card.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.card,
                                        ),
                                        boxShadow: AppShadows.softCard,
                                      ),
                                      child: CheckboxListTile(
                                        title: Text(
                                          '${mesa.nombreONumero} - Bs. ${mesa.precioReserva}',
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.textPrimary,
                                            fontSize: 15,
                                          ),
                                        ),
                                        value: mesasSeleccionadas[mesa.id],
                                        onChanged:
                                            (v) => setState(
                                              () =>
                                                  mesasSeleccionadas[mesa.id] =
                                                      v ?? false,
                                            ),
                                        activeColor: AppColors.primaryAccent,
                                        checkColor: AppColors.textPrimary,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                    const SizedBox(height: AppSpacing.xxl),

                    _seccionTitulo('Combos'),
                    combos.isEmpty
                        ? _outOfStock()
                        : Column(
                          children: combos.map((c) => _comboCard(c)).toList(),
                        ),

                    const SizedBox(height: AppSpacing.xxl),

                    Text(
                      'Total ítems: $totalItems',
                      style: AppTextStyles.titleSection.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Center(
                      child: totalItems == 0
                          ? Text(
                              'Agrega productos para continuar',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                              ),
                            )
                          : _botonComprar(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
    );
  }

  Widget _seccionTitulo(String titulo) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      titulo,
      style: AppTextStyles.titleSection.copyWith(fontSize: 22),
    ),
  );

  Widget _outOfStock() => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      'OUT OF STOCK',
      style: AppTextStyles.body.copyWith(
        color: Colors.redAccent,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // 🔹 STEP PER REUTILIZABLE PARA CANTIDAD (MISMO DISEÑO EN MANILLAS Y COMBOS)
  Widget _buildCantidadStepper({
    required int cantidad,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.remove_circle,
            color: Colors.redAccent,
          ),
          onPressed: onRemove,
        ),
        Text(
          '$cantidad',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.add_circle,
            color: Colors.greenAccent,
          ),
          onPressed: onAdd,
        ),
      ],
    );
  }

  Widget _itemCantidad({
    required String nombre,
    required double precio,
    required int cantidad,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.softCard,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '$nombre - Bs. ${precio.toStringAsFixed(2)}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildCantidadStepper(
              cantidad: cantidad,
              onAdd: onAdd,
              onRemove: onRemove,
            ),
          ],
        ),
      ),
    );
  }

  Widget _comboCard(DetalleComboDto c) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.softCard,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.imagenUrl != null && c.imagenUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.button),
                child: Image.network(
                  c.imagenUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(
                            AppRadius.button,
                          ),
                        ),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white70,
                        ),
                      ),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: const Icon(Icons.image, color: Colors.white70),
              ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.nombre,
                    style: AppTextStyles.titleSection.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  if (c.descripcion != null && c.descripcion!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        c.descripcion!,
                        style: GoogleFonts.orbitron(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bs. ${c.precio.toStringAsFixed(2)}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildCantidadStepper(
              cantidad: carritoCombos[c.id]!,
              onAdd:
                  () => setState(
                    () => carritoCombos[c.id] = carritoCombos[c.id]! + 1,
                  ),
              onRemove: () {
                if (carritoCombos[c.id]! > 0) {
                  setState(
                    () => carritoCombos[c.id] = carritoCombos[c.id]! - 1,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonComprar() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: AppShadows.softCard,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: totalItems == 0 ? null : _comprar,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 70,
            vertical: 18,
          ),
          child: Text(
            'Comprar',
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
