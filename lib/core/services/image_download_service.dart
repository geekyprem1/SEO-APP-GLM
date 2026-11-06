import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../network/dio_client.dart';

/// Abstract image download service interface.
abstract class ImageDownloadService {
  /// Downloads an image from [imageUrl] and saves it to the device gallery.
  /// Returns true on success.
  Future<bool> downloadAndSave(String imageUrl);
}

/// Implementation using Dio + Gal (gallery saver).
class ImageDownloadServiceImpl implements ImageDownloadService {
  ImageDownloadServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<bool> downloadAndSave(String imageUrl) async {
    if (imageUrl.trim().isEmpty) return false;

    String? filePath;
    try {
      // Request gallery permissions.
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) return false;
      }

      // Download image to a uniquely-named temp file.
      final tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}/thumbnail_${const Uuid().v4()}.png';

      await _dio.download(
        imageUrl,
        filePath,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save to gallery.
      await Gal.putImage(filePath, album: 'Tubora');
      return true;
    } catch (_) {
      return false;
    } finally {
      // Always clean up the temp file so the cache directory cannot grow
      // unbounded with every download.
      final path = filePath;
      if (path != null) {
        try {
          final file = File(path);
          if (await file.exists()) await file.delete();
        } catch (_) {
          // Best-effort cleanup; never mask the result.
        }
      }
    }
  }
}

/// Provider for [ImageDownloadService].
final imageDownloadServiceProvider = Provider<ImageDownloadService>((ref) {
  return ImageDownloadServiceImpl(DioClient.instance);
});
