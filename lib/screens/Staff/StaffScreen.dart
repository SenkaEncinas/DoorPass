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
          // Escanear QR
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            tooltip: "Escanear QR",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EscanerQrScreen()),
              );
            },
          ),

          // Cerrar Sesión
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

                    return Container(
                      margin:
                          const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.card.withOpacity(0.98),
                        borderRadius:
                            BorderRadius.circular(AppRadius.card),
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
                            trailing: Icon(
                              isOpen ? Icons.expand_less : Icons.expand_more,
                              color: AppColors.textPrimary,
                            ),
                            onTap: () {
                              setState(() {
                                expanded[index] = !expanded[index];
                              });
                            },
                          ),
                          if (isOpen) ...[
                            const Divider(
                              height: 1,
                              color: Colors.white10,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
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
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    "Manillas compradas:",
                                    style:
                                        AppTextStyles.body.copyWith(
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
                                          bottom: 4.0,
                                        ),
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
                                        top: AppSpacing.xs,
                                      ),
                                      child: Text(
                                        "No hay manillas registradas",
                                        style:
                                            GoogleFonts.orbitron(
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
                color: highlight ? AppColors.textSecondary : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
