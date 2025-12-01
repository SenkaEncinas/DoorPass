import 'package:doorpass/screens/LoginScreen.dart';
import 'package:doorpass/screens/Staff/EscanerQrScreen.dart';
import 'package:flutter/material.dart';
import 'package:doorpass/services/staff_service.dart';
import 'package:doorpass/models/Compras/DetalleCompraDto.dart';
import 'package:google_fonts/google_fonts.dart';

// CONSTANTES
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_radius.dart';
import 'package:doorpass/screens/constants/app_shadows.dart';

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

  Future<List<DetalleCompraDto>> _staff_service_getSafely() async {
    try {
      return await _staffService.getHistorialCompras();
    } catch (e) {
      debugPrint('Error cargando historial: $e');
      return [];
    }
  }

  // =========================
  // INVALIDAR UNA COMPRA
  // =========================
  Future<void> _invalidarCompra(int compraId) async {
    setState(() => loading = true);

    final ok = await _staffService.invalidarCompra(compraId);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Compra invalidada correctamente")),
      );
      await cargarHistorial(); // refresca
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ No se pudo invalidar la compra")),
      );
    }
  }

  void _confirmarInvalidacion(DetalleCompraDto compra) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text("Invalidar compra"),
        content: Text(
          "¿Seguro que quieres invalidar la compra #${compra.compraId}?\n"
          "Esto la marcará como usada/cancelada.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _invalidarCompra(compra.compraId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Sí, invalidar"),
          ),
        ],
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
          "Panel de Staff",
          style: AppTextStyles.titleSection.copyWith(
            color: AppColors.textSecondary,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            tooltip: "Escanear QR",
            onPressed: () async {
              final compraId = await Navigator.push<int?>(
                context,
                MaterialPageRoute(builder: (_) => const EscanerQrScreen()),
              );

              if (compraId != null) {
                _invalidarCompra(compraId);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.progress),
            )
          : historial.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      "No hay historial de compras",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.emptyState.copyWith(fontSize: 18),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: historial.length,
                  itemBuilder: (context, index) {
                    final compra = historial[index];
                    final isOpen = expanded[index];
                    final activa = compra.estaActiva;

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.card.withOpacity(0.98),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        boxShadow: AppShadows.softCard,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            title: Text(
                              "Compra #${compra.compraId}",
                              style: AppTextStyles.titleSection.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "Comprador: ${compra.nombreUsuario}",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),

                            // ✅ MODIFICADO: botón visible siempre
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.block,
                                    color: activa ? Colors.red : Colors.grey,
                                  ),
                                  tooltip: activa
                                      ? "Invalidar compra"
                                      : "Ya invalidada",
                                  onPressed: activa
                                      ? () => _confirmarInvalidacion(compra)
                                      : null,
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: activa ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    activa ? "ACTIVA" : "INVALIDADA",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isOpen
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: AppColors.textPrimary,
                                ),
                              ],
                            ),

                            onTap: () {
                              setState(() {
                                expanded[index] = !expanded[index];
                              });
                            },
                          ),

                          if (isOpen) ...[
                            const Divider(height: 1, color: Colors.white10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
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
                                    highlight: true,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  _linea(
                                    "Mesa reservada:",
                                    compra.mesaReservada ?? "Ninguna",
                                  ),

                                  // Botón grande dentro del detalle (se mantiene)
                                  const SizedBox(height: AppSpacing.md),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.block),
                                      label: Text(
                                        activa
                                            ? "INVALIDAR COMPRA"
                                            : "COMPRA YA INVALIDADA",
                                      ),
                                      onPressed: activa
                                          ? () => _confirmarInvalidacion(compra)
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        disabledBackgroundColor:
                                            Colors.grey.shade700,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    "Manillas compradas:",
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  if (compra.manillasCompradas.isNotEmpty)
                                    ...compra.manillasCompradas.map((m) {
                                      final precio =
                                          (m.precioPagado ?? 0).toDouble();
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 4.0),
                                        child: Text(
                                          "- ${m.nombreManilla} (x${m.cantidad}) — Bs. ${precio.toStringAsFixed(2)}",
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }).toList()
                                  else
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: AppSpacing.xs),
                                      child: Text(
                                        "No hay manillas registradas",
                                        style: GoogleFonts.orbitron(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _linea(String titulo, String valor, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$titulo ",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: valor,
              style: AppTextStyles.body.copyWith(
                color: highlight
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
