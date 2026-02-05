import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart'; // para firma HMAC-SHA1 en destroy
import 'package:http/http.dart' as http;
//import 'package:mi_proyecto_guia4/logic/bloc/elemento_bloc/elemento_event.dart';

/// Resultado de subida a Cloudinary
class CloudinaryUploadResult {
  final String url; // secure_url
  final String publicId; // public_id

  CloudinaryUploadResult({required this.url, required this.publicId});

  @override
  String toString() => 'CloudinaryUploadResult(url: $url, publicId: $publicId)';
}

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  /// Para Admin API (destroy). Si no usarás destroy, puedes dejarlos en blanco.
  final String? apiKey;
  final String? apiSecret;

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
    this.apiKey,
    this.apiSecret,
  });

  Uri _buildImageUploadUri() {
    final name = cloudName.trim();
    return Uri.parse('https://api.cloudinary.com/v1_1/$name/image/upload');
  }

  Uri _buildImageDestroyUri() {
    final name = cloudName.trim();
    // Admin API destroy: POST a /image/destroy
    // https://api.cloudinary.com/v1_1/<cloud_name>/image/destroy
    return Uri.parse('https://api.cloudinary.com/v1_1/$name/image/destroy');
  }

  /// Sube un archivo local y retorna URL + publicId.
  Future<CloudinaryUploadResult> uploadImageFile(
    File file, {
    String? folder,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = _buildImageUploadUri();

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset.trim();

    if (folder != null && folder.isNotEmpty) {
      request.fields['folder'] = folder.trim();
    }

    final fileName = file.path.split(Platform.pathSeparator).last;
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path, filename: fileName),
    );

    http.StreamedResponse streamed;
    try {
      streamed = await request.send().timeout(timeout);
    } on Exception catch (e) {
      throw Exception('No se pudo enviar la solicitud a Cloudinary: $e');
    }

    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 200) {
      final shortBody = resp.body.length > 200
          ? resp.body.substring(0, 200)
          : resp.body;
      throw Exception(
        'Error subiendo a Cloudinary: ${resp.statusCode} $shortBody',
      );
    }

    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    final url = map['secure_url'] as String?;
    final publicId = map['public_id'] as String?;
    // final deleteToken = map['delete_token'] as String?; // si activas esa opción

    if (url == null || url.isEmpty) {
      throw Exception('Cloudinary no devolvió secure_url. Body: ${resp.body}');
    }
    if (publicId == null || publicId.isEmpty) {
      // Normalmente siempre viene public_id; si no, mejor avisar
      throw Exception('Cloudinary no devolvió public_id. Body: ${resp.body}');
    }

    return CloudinaryUploadResult(
      url: url,
      publicId: publicId,
      // deleteToken: deleteToken,
    );
  }

  /// (Opcional, útil para Flutter Web) Sube bytes y retorna URL + publicId.
  Future<CloudinaryUploadResult> uploadImageBytes(
    List<int> bytes, {
    String? folder,
    Duration timeout = const Duration(seconds: 30),
    String fileName = 'upload.jpg',
  }) async {
    final uri = _buildImageUploadUri();

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset.trim();

    if (folder != null && folder.isNotEmpty) {
      request.fields['folder'] = folder.trim();
    }

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    http.StreamedResponse streamed;
    try {
      streamed = await request.send().timeout(timeout);
    } on Exception catch (e) {
      throw Exception('No se pudo enviar la solicitud a Cloudinary: $e');
    }

    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 200) {
      final shortBody = resp.body.length > 200
          ? resp.body.substring(0, 200)
          : resp.body;
      throw Exception(
        'Error subiendo a Cloudinary: ${resp.statusCode} $shortBody',
      );
    }

    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    final url = map['secure_url'] as String?;
    final publicId = map['public_id'] as String?;
    // final deleteToken = map['delete_token'] as String?;

    if (url == null || url.isEmpty) {
      throw Exception('Cloudinary no devolvió secure_url. Body: ${resp.body}');
    }
    if (publicId == null || publicId.isEmpty) {
      throw Exception('Cloudinary no devolvió public_id. Body: ${resp.body}');
    }

    return CloudinaryUploadResult(
      url: url,
      publicId: publicId,
      // deleteToken: deleteToken,
    );
  }

  /// Elimina una imagen por su publicId usando Admin API (destroy).
  ///
  /// Requiere apiKey y apiSecret (firma). Si no las pasaste en el constructor,
  /// lanzará una excepción. Alternativamente, se puede usar delete_token si
  /// guardas ese valor del upload y habilitas delete-by-token en tu configuración.
  Future<void> deleteImage({required String publicId}) async {
    if ((apiKey?.isEmpty ?? true) || (apiSecret?.isEmpty ?? true)) {
      throw Exception(
        'Para borrar imágenes por publicId se requiere apiKey y apiSecret de Cloudinary.',
      );
    }

    final uri = _buildImageDestroyUri();
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();

    // Firma: concatenar pares en orden alfabético de parámetros (sin api_key y signature),
    // aquí usamos: public_id y timestamp
    final toSign = 'public_id=$publicId&timestamp=$timestamp${apiSecret!}';
    final signature = sha1.convert(utf8.encode(toSign)).toString();

    final body = {
      'public_id': publicId,
      'timestamp': timestamp,
      'api_key': apiKey!,
      'signature': signature,
    };

    http.Response resp;
    try {
      resp = await http
          .post(uri, body: body)
          .timeout(const Duration(seconds: 30));
    } on Exception catch (e) {
      throw Exception('No se pudo enviar destroy a Cloudinary: $e');
    }

    if (resp.statusCode != 200) {
      final shortBody = resp.body.length > 200
          ? resp.body.substring(0, 200)
          : resp.body;
      throw Exception(
        'Error borrando en Cloudinary: ${resp.statusCode} $shortBody',
      );
    }

    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    // Cloudinary suele devolver { "result": "ok" } en éxito
    if (map['result'] != 'ok') {
      throw Exception(
        'No se pudo eliminar la imagen en Cloudinary_service.dart. Body: ${resp.body}',
      );
    }
  }

  // add(LoadElementos loadElementos) {}
}
