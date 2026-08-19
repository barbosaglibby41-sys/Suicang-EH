import 'dart:typed_data';
import 'dart:ui' as ui;

class DecodedImage {
  const DecodedImage({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;

  int get estimatedCostBytes => width * height * 4;
}

class ImageDecoder {
  const ImageDecoder();

  Future<DecodedImage> decode(
    Uint8List source, {
    required int targetPixels,
  }) async {
    final codec = await ui.instantiateImageCodec(
      source,
      targetWidth: targetPixels,
      allowUpscaling: false,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final width = image.width;
    final height = image.height;
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    codec.dispose();
    if (data == null) {
      throw StateError('Image decode did not produce bytes.');
    }
    return DecodedImage(
      bytes: data.buffer.asUint8List(),
      width: width,
      height: height,
    );
  }
}
