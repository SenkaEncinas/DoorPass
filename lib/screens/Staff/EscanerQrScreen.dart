import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html; // si no lo usas en nada más, luego se puede quitar
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:jsqr/jsqr.dart';
import 'dart:ui' as ui;

// CONSTANTES
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_gradients.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_radius.dart';
import 'package:doorpass/screens/constants/app_shadows.dart';

class EscanerQrScreen extends StatefulWidget {
  const EscanerQrScreen({super.key});

  @override
  State<EscanerQrScreen> createState() => _EscanerQrScreenState();
}

class _EscanerQrScreenState extends State<EscanerQrScreen> {
  bool _procesando = false;

  Future<void> _seleccionarArchivo() async {
    if (_procesando) return;

    setState(() => _procesando = true);

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null) {
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se seleccionó ningún archivo")),
      );
      return;
    }

    try {
      String? qrData;

      if (kIsWeb) {
        // Web: convertir bytes a Image y luego procesar con jsqr
        final bytes = result.files.first.bytes!;
        final qr = await _leerQrWeb(bytes);
        qrData = qr;
      } else {
        // Móvil/desktop: usar path
        final path = result.files.first.path!;
        qrData = await QrCodeToolsPlugin.decodeFrom(path);
      }

      if (qrData == null) {
        throw Exception("QR no legible");
      }

      final data = jsonDecode(qrData);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultadoQrScreen(data: data),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("QR inválido: $e")),
      );
    }

    setState(() => _procesando = false);
  }

  /// Función para leer QR en web usando Canvas + jsqr
  Future<String?> _leerQrWeb(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final pixels = byteData!.buffer.asUint8List();
    final result = jsQR(pixels, image.width, image.height);
    return result?.data;
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
          "Escanear QR",
          style: AppTextStyles.titleSection.copyWith(
            color: AppColors.textSecondary,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono grande de QR
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.card.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: AppShadows.softCard,
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                "Selecciona una imagen con código QR\ny validaremos la entrada.",
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Botón principal (gradiente)
              _primaryButton(
                text: _procesando ? "Procesando..." : "Seleccionar QR",
                onTap: _procesando ? null : _seleccionarArchivo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    return Opacity(
      opacity: isDisabled ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: AppShadows.softCard,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.button),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Center(
              child: Text(
                // El texto se setea desde el botón padre con Orbitron en el theme general
                'Seleccionar QR',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ResultadoQrScreen extends StatelessWidget {
  final Map data;

  const ResultadoQrScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final prettyJson = const JsonEncoder.withIndent("  ").convert(data);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        centerTitle: true,
        elevation: 4,
        shadowColor: AppColors.primaryAccent.withOpacity(0.4),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Resultado del QR",
          style: AppTextStyles.titleSection.copyWith(
            color: AppColors.textSecondary,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Datos decodificados",
              style: AppTextStyles.titleSection.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card.withOpacity(0.98),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: AppShadows.softCard,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SingleChildScrollView(
                  child: SelectableText(
                    prettyJson,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontFamily: 'monospace',
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
