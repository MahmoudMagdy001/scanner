import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImagePreprocessorConfig {
  const ImagePreprocessorConfig({
    this.maxDimension = 1600,
    this.contrast = 1.25,
    this.brightness = 1.05,
    this.applySharpen = true,
    this.grayscale = true,
    this.jpegQuality = 92,
  });

  final int maxDimension;
  final double contrast;
  final double brightness;
  final bool applySharpen;
  final bool grayscale;
  final int jpegQuality;
}

/// Top-level function so it can run inside `compute()` (isolate-safe: no
/// closures over instance state).
Uint8List _enhanceImageBytes(({Uint8List bytes, ImagePreprocessorConfig config}) args) {
  final decoded = img.decodeImage(args.bytes);
  if (decoded == null) return args.bytes;

  var image = decoded;

  // Downscale first – cheaper for every following operation and shrinks the
  // base64 payload sent over the network.
  final longestSide = image.width > image.height ? image.width : image.height;
  if (longestSide > args.config.maxDimension) {
    image = img.copyResize(
      image,
      width: image.width >= image.height ? args.config.maxDimension : null,
      height: image.height > image.width ? args.config.maxDimension : null,
      interpolation: img.Interpolation.average,
    );
  }

  if (args.config.grayscale) {
    image = img.grayscale(image);
  }

  image = img.adjustColor(image, contrast: args.config.contrast, brightness: args.config.brightness);

  if (args.config.applySharpen) {
    // Simple unsharp-mask style 3x3 kernel – helps digit edges stand out
    // for OCR without introducing much noise.
    image = img.convolution(image, filter: [0, -1, 0, -1, 5, -1, 0, -1, 0]);
  }

  return Uint8List.fromList(img.encodeJpg(image, quality: args.config.jpegQuality));
}

/// Preprocesses card images on-device before they're sent to OCR.
class ImagePreprocessor {
  const ImagePreprocessor({this.config = const ImagePreprocessorConfig()});

  final ImagePreprocessorConfig config;

  Future<File> enhance(File input) async {
    final bytes = await input.readAsBytes();

    final enhancedBytes = await compute(_enhanceImageBytes, (bytes: bytes, config: config));

    final tempDir = await getTemporaryDirectory();
    final outPath = p.join(tempDir.path, 'card_scan_${DateTime.now().microsecondsSinceEpoch}.jpg');
    final outFile = File(outPath);
    await outFile.writeAsBytes(enhancedBytes, flush: true);
    return outFile;
  }
}
