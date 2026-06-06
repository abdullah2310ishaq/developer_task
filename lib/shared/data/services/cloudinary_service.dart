import 'dart:io';

import 'package:dio/dio.dart';
import 'package:developer_task/core/config/env_config.dart';

class CloudinaryService {
  CloudinaryService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<String> uploadImage(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split(Platform.pathSeparator).last,
      ),
      'upload_preset': EnvConfig.cloudinaryUploadPreset,
    });

    final response = await _dio.post<Map<String, dynamic>>(
      EnvConfig.cloudinaryUploadUrl,
      data: formData,
    );

    final url = response.data?['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw StateError('Cloudinary upload failed');
    }
    return url;
  }
}
