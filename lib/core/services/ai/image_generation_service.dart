import 'models.dart';

/// Abstract image generation service interface.
///
/// Used by the Thumbnail Generator feature. Swapping the image provider
/// (Replicate → DALL-E / Stability AI) requires only implementing this
/// interface and changing the Riverpod override — no UI changes.
///
/// MVP implementation: [CloudFunctionsImageService] which routes requests
/// through Firebase Cloud Functions (Replicate FLUX.1 Schnell, server-side key).
abstract class ImageGenerationService {
  /// Generates an image for the given [request].
  /// Returns an [ImageResult] containing the image URL.
  Future<ImageResult> generateImage({required ImageRequest request});
}
