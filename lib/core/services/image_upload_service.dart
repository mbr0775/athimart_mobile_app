// lib/core/services/image_upload_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadService {
  static final _supabase = Supabase.instance.client;
  static const _bucket = 'product-images'; // Supabase Storage bucket name

  /// Uploads a single image file → returns its public URL
  static Future<String> uploadImage(File file) async {
    final userId = _supabase.auth.currentUser?.id ?? 'anon';
    final ext = file.path.split('.').last.toLowerCase();
    final fileName =
        '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _supabase.storage.from(_bucket).upload(
      fileName,
      file,
      fileOptions: FileOptions(
        contentType: _mimeType(ext),
        upsert: false,
      ),
    );

    final url =
        _supabase.storage.from(_bucket).getPublicUrl(fileName);
    return url;
  }

  /// Uploads multiple images in parallel → returns list of public URLs
  static Future<List<String>> uploadImages(List<File> files) async {
    final results = await Future.wait(files.map(uploadImage));
    return results;
  }

  /// Deletes an image by its full public URL
  static Future<void> deleteImage(String publicUrl) async {
    try {
      // Extract path from URL: everything after /storage/v1/object/public/{bucket}/
      final uri = Uri.parse(publicUrl);
      final segments = uri.pathSegments;
      final bucketIdx = segments.indexOf(_bucket);
      if (bucketIdx != -1 && bucketIdx < segments.length - 1) {
        final path = segments.sublist(bucketIdx + 1).join('/');
        await _supabase.storage.from(_bucket).remove([path]);
      }
    } catch (_) {}
  }

  static String _mimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}