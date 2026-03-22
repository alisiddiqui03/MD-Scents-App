import 'dart:io';

import 'package:dio/dio.dart';

import '../config/cloudinary_config.dart';

/// Uploads images to Cloudinary and returns the public URL.
/// Uses unsigned upload preset (no API secret in app).
class CloudinaryService {
  CloudinaryService();

  static const String _baseUrl =
      'https://api.cloudinary.com/v1_1/{cloud_name}/image/upload';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Uploads [file] to Cloudinary. Returns secure URL or throws.
  Future<String> uploadImage(File file) async {
    if (!CloudinaryConfig.isConfigured) {
      throw StateError(
        'Cloudinary not configured. Set cloudName and uploadPreset in '
        'lib/app/config/cloudinary_config.dart',
      );
    }

    final url = _baseUrl.replaceAll('{cloud_name}', CloudinaryConfig.cloudName);

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
      'upload_preset': CloudinaryConfig.uploadPreset,
    });

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: formData,
      );

      final data = response.data;
      if (data == null) throw StateError('Cloudinary returned empty response');

      final secureUrl = data['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw StateError('Cloudinary response missing secure_url');
      }
      return secureUrl;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final errorObj = responseData['error'];
        if (errorObj is Map<String, dynamic>) {
          final message = errorObj['message'] as String?;
          if (message != null && message.isNotEmpty) {
            throw StateError(_friendlyCloudinaryError(message));
          }
        }
      }
      throw StateError(
        'Image upload failed. Check internet and Cloudinary preset settings.',
      );
    }
  }

  String _friendlyCloudinaryError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('upload preset') && lower.contains('not found')) {
      return 'Upload preset not found. Check uploadPreset in cloudinary_config.dart';
    }
    if (lower.contains('unsigned') && lower.contains('not allowed')) {
      return 'Preset is not unsigned. Set preset mode to Unsigned in Cloudinary';
    }
    if (lower.contains('cloud name')) {
      return 'Invalid cloud name. Check cloudName in cloudinary_config.dart';
    }
    return message;
  }
}
