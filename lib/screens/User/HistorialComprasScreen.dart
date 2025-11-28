import 'dart:convert';

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:html' as html show AnchorElement, Blob, Url;

import 'package:flutter/material.dart';
import 'package:doorpass/services/compras_service.dart';
import 'package:doorpass/models/Compras/DetalleCompraDto.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

// CONSTANTES
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_gradients.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_radius.dart';
import 'package:doorpass/screens/constants/app_shadows.dart';

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

  Future<void> _descargarQr(DetalleCompraDto compra) async {
    try {
      final painter = QrPainter(
        data: _generarJsonCompra(compra),
        version: QrVersions.auto,
        gapless: true,
        // colores del QR (negro sobre blanco)
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      );

      final uiImageData = await painter.toImageData(
        1024,
        format: ui.ImageByteFormat.png,
      );

      if (uiImageData == null) return;

      final bytes = uiImageData.buffer.asUint8List();

      final blob = html.Blob([bytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor =
          html.AnchorElement(href: url)
            ..download = 'compra_${compra.compraId}.png'
            ..click();

      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al descargar el QR',
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _cancelarCompra(DetalleCompraDto compra) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.appBar,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            title: Text('Cancelar compra', style: AppTextStyles.titleSection),
            content: Text(
              '¿Seguro que quieres cancelar la compra #${compra.compraId}?',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'No',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Sí, cancelar',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmar != true) return;

    final exito = await _service.cancelarCompra(compra.compraId);

    if (!mounted) return;

    if (exito) {
      setState(() {
        _futureHistorial = _service.getMiHistorial();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Compra #${compra.compraId} cancelada con éxito',
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
          backgroundColor: Colors.greenAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo cancelar la compra #${compra.compraId}',
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

void _mostrarDetalleCompra(DetalleCompraDto compra) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.appBar,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// QR CON LA INFO DE LA COMPRA
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: AppShadows.softCard,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: QrImageView(
                  data: _generarJsonCompra(compra),
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              "Compra #${compra.compraId}",
              style: AppTextStyles.titleLarge,
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              compra.nombreBoliche,
              style: AppTextStyles.titleSection.copyWith(
                color: AppColors.textMuted,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Fecha: ${compra.fechaCompra.toLocal()}",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "Tipo de Compra: ${compra.tipoCompra}",
              style: AppTextStyles.titleSection,
            ),
            const SizedBox(height: AppSpacing.md),

            if (compra.manillasCompradas.isNotEmpty) ...[
              Text(
                "Manillas Compradas:",
                style: AppTextStyles.titleSection.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...compra.manillasCompradas.map(
                (m) => Text(
                  "- ${m.nombreManilla} x${m.cantidad}",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            if (compra.combosComprados.isNotEmpty) ...[
              Text(
                "Combos Comprados:",
                style: AppTextStyles.titleSection.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...compra.combosComprados.map(
                (c) => Text(
                  "- ${c.nombreCombo} x${c.cantidad}",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            if (compra.mesaReservada != null)
              Text(
                "Mesa Reservada: ${compra.mesaReservada}",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),

            const SizedBox(height: AppSpacing.md),

            Text(
              "Total Pagado: Bs ${compra.totalPagado.toStringAsFixed(2)}",
              style: AppTextStyles.titleSection.copyWith(
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  compra.estaActiva ? Icons.check_circle : Icons.cancel,
                  color: compra.estaActiva
                      ? Colors.lightBlueAccent
                      : Colors.redAccent,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  compra.estaActiva ? "Activa" : "Cancelada",
                  style: AppTextStyles.titleSection.copyWith(
                    color: compra.estaActiva
                        ? Colors.lightBlueAccent
                        : Colors.redAccent,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // CERRAR
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: Text(
                    "Cerrar",
                    style: AppTextStyles.button,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // DESCARGAR QR
                ElevatedButton(
                  onPressed: () => _descargarQr(compra),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: Text(
                    "Descargar QR",
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.appBar,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // CANCELAR COMPRA (solo si está activa)
                if (compra.estaActiva)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _cancelarCompra(compra);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: Text(
                      "Cancelar compra",
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textPrimary,
                      ),
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
//IVAN SE LA COME

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Historial de Compras",
          style: AppTextStyles.titleSection.copyWith(
            color: AppColors.textSecondary,
            fontSize: 20,
          ),
        ),
        elevation: 4,
        shadowColor: AppColors.primaryAccent.withOpacity(0.4),
      ),
      body: FutureBuilder<List<DetalleCompraDto>>(
        future: _futureHistorial,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.progress),
            );
          }

          final compras = snapshot.data!;

          if (compras.isEmpty) {
            return Center(
              child: Text(
                "No tienes compras aún ✨",
                style: AppTextStyles.emptyState.copyWith(fontSize: 20),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: compras.length,
            itemBuilder: (context, index) {
              final compra = compras[index];

              final Gradient gradient =
                  compra.estaActiva
                      ? AppGradients.primary
                      : LinearGradient(
                        colors: [
                          Colors.redAccent.withOpacity(0.7),
                          Colors.redAccent.withOpacity(0.4),
                        ],
                      );

              final Color textColor =
                  compra.estaActiva
                      ? AppColors.textPrimary
                      : Colors.red[900] ?? Colors.red;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: AppShadows.softCard,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
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
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        compra.nombreBoliche,
                        style: GoogleFonts.orbitron(
                          color: textColor.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
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
                          : const Icon(
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
