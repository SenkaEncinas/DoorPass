import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:jsqr/jsqr.dart';
import 'dart:ui' as ui;

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
        MaterialPageRoute(builder: (_) => ResultadoQrScreen(data: data)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("QR inválido: $e")));
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Escanear QR"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _seleccionarArchivo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          ),
          child: Text(
            _procesando ? "Procesando..." : "Seleccionar QR",
            style: const TextStyle(fontSize: 18, color: Colors.white),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Resultado del QR")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            const JsonEncoder.withIndent("  ").convert(data),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
