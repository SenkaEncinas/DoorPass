import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // TODO: pon aquí tu cloud name real (el del dashboard)
  static const String _cloudName = 'dsrzryu3d';

  // Ya lo creaste en Cloudinary como unsigned
  static const String _uploadPreset = 'flutter_unsigned';

  static String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Sube una imagen a Cloudinary y devuelve la URL segura (secure_url).
  ///
  /// [fileBytes] → bytes de la imagen (Uint8List)
  /// [fileName]  → nombre del archivo, ej: "foto.png"
  static Future<String?> uploadImage({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_uploadUrl),
      )
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
          ),
        );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        // Esta es la URL que guardarás en imagenUrl
        return data['secure_url'] as String?;
      } else {
        print('Error Cloudinary (${response.statusCode}): $body');
        return null;
      }
    } catch (e) {
      print('Excepción al subir a Cloudinary: $e');
      return null;
    }
  }
}
