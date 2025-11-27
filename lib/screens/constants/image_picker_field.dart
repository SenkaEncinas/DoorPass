import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// CONSTANTES tuyas
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_radius.dart';

class ImagePickerField extends StatefulWidget {
  final String? initialUrl;
  final void Function(Uint8List? bytes, String? name) onChanged;

  const ImagePickerField({
    super.key,
    this.initialUrl,
    required this.onChanged,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _bytes;
  String? _name;
  String? _url;

  @override
  void initState() {
    super.initState();
    _url = widget.initialUrl;
  }

  Future<void> _pick() async {
    try {
      if (kIsWeb) {
        // ✅ WEB: usando file_picker (más estable)
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true, // importante para tener bytes
        );

        if (result == null || result.files.isEmpty) return;

        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes == null) return;

        if (!mounted) return;
        setState(() {
          _bytes = bytes;
          _name = file.name;
          _url = null;
        });

        widget.onChanged(_bytes, _name);
      } else {
        // ✅ MOBILE: usando image_picker normal
        final XFile? picked = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
          maxWidth: 1600,
        );
        if (picked == null) return;

        final bytes = await picked.readAsBytes();

        if (!mounted) return;
        setState(() {
          _bytes = bytes;
          _name = picked.name;
          _url = null;
        });

        widget.onChanged(_bytes, _name);
      }
    } catch (e) {
      // Para que no “mate” la app en web
      debugPrint("Error picking image: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error seleccionando imagen: $e"),
        ),
      );
    }
  }

  void _clear() {
    setState(() {
      _bytes = null;
      _name = null;
      _url = null;
    });
    widget.onChanged(null, null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Imagen (opcional)",
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pick,
                icon: const Icon(Icons.photo_library),
                label: const Text("Seleccionar imagen"),
              ),
              const SizedBox(width: 8),
              if (_bytes != null || (_url != null && _url!.isNotEmpty))
                TextButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.close),
                  label: const Text("Quitar"),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          if (_bytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Image.memory(
                _bytes!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else if (_url != null && _url!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Image.network(
                _url!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[900],
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white70,
                  ),
                ),
              ),
            )
          else
            Text(
              "No hay imagen seleccionada",
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
