import 'dart:async' show unawaited;
import 'dart:io';

import 'package:flutter_native_image_v2/flutter_native_image_v2.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:qrscanner/core/ocr/ocr_logger.dart';

/// Default target min resolution for upscaling (longest side in pixels).
const int kDefaultMinLongestSide = 1600;

/// Default target max resolution for downscaling (longest side in pixels).
const int kDefaultMaxLongestSide = 2200;

/// Default JPEG compression quality (1-100).
/// 75-85 range provides visually/functionally lossless quality for printed text/digits
/// while significantly reducing file size compared to 90+.
const int kDefaultJpegQuality = 85;

/// Minimal longest side threshold below which upscaling is triggered.
/// Images with longest side >= upscaleFloor (e.g. 800px) already have enough detail
/// for OCR digit extraction and do not benefit from artificial upscaling.
const int kDefaultUpscaleFloor = 800;

class ImagePreprocessorConfig {
  const ImagePreprocessorConfig({
    this.minLongestSide = kDefaultMinLongestSide,
    this.maxLongestSide = kDefaultMaxLongestSide,
    this.jpegQuality = kDefaultJpegQuality,
    this.upscaleFloor = kDefaultUpscaleFloor,
  });

  /// Target longest side size when upscaling very low-resolution images (< [upscaleFloor]).
  final int minLongestSide;

  /// Max longest side allowed. Images larger than this are downscaled to reduce upload payload.
  final int maxLongestSide;

  /// JPEG quality setting. 80 is optimal for OCR of printed digits (reduces byte size without image degradation).
  final int jpegQuality;

  /// Floor threshold below which upscaling kicks in. Images above this size are not artificially upscaled.
  final int upscaleFloor;
}

/// Preprocesses card images on-device before they're sent to OCR.
// ponytail: Auto-cropping feasibility note:
// Auto-cropping to scratch-panel/serial bounding box would require ML Kit or edge detection dependencies.
// Currently full card native resizing to ~1200-1800px with 80% JPEG quality keeps payload low (<150KB),
// making full-image upload fast enough without adding extra vision dependencies.
class ImagePreprocessor {
  const ImagePreprocessor({this.config = const ImagePreprocessorConfig()});

  final ImagePreprocessorConfig config;

  Future<File> enhance(File input) async {
    final sw = Stopwatch()..start();
    final inputSize = await input.length();
    logOcr('[1/5] 📂 Reading image file (${(inputSize / 1024).toStringAsFixed(1)} KB)...', name: 'OCR_PREPROCESS');

    // 1. Decode image properties natively
    final swDecode = Stopwatch()..start();
    final properties = await FlutterNativeImage.getImageProperties(input.path);
    final width = properties.width ?? 0;
    final height = properties.height ?? 0;
    logOcr('  [main] decode: ${swDecode.elapsedMilliseconds}ms', name: 'OCR_PREPROCESS');
    logOcr('  [main] source dims: ${width}x$height', name: 'OCR_PREPROCESS');

    logOcr('[2/5] ✅ File read done — ${sw.elapsedMilliseconds}ms', name: 'OCR_PREPROCESS');

    final longestSide = width > height ? width : height;
    var targetWidth = width;
    var targetHeight = height;
    var mode = 'no-resize';

    // Only upscale if image resolution is below upscaleFloor (800px).
    // Avoid upscaling adequate photos (800px-1200px) which inflates size without adding detail.
    if (longestSide < config.upscaleFloor) {
      final scale = config.minLongestSide / longestSide;
      targetWidth = (width * scale).round();
      targetHeight = (height * scale).round();
      mode = 'upscale';
    } else if (longestSide > config.maxLongestSide) {
      final scale = config.maxLongestSide / longestSide;
      targetWidth = (width * scale).round();
      targetHeight = (height * scale).round();
      mode = 'downscale';
    }

    // 2. Perform native resizing and JPEG encoding file-to-file
    // ponytail: FlutterNativeImage resizes/compresses completely natively,
    // avoiding huge Dart heap allocations, file reads/writes, or isolate overhead.
    final swCompress = Stopwatch()..start();
    final compressedFile = await FlutterNativeImage.compressImage(
      input.path,
      quality: config.jpegQuality,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
    logOcr(
      '  [main] native resize & encode ($mode): ${swCompress.elapsedMilliseconds}ms | out dims: ${targetWidth}x$targetHeight',
      name: 'OCR_PREPROCESS',
    );

    logOcr(
      '[3/5] ✅ Image processing done — ${sw.elapsedMilliseconds}ms | output ${(await compressedFile.length() / 1024).toStringAsFixed(1)} KB',
      name: 'OCR_PREPROCESS',
    );

    final tempDir = await getTemporaryDirectory();
    final outPath = p.join(tempDir.path, 'card_scan_${DateTime.now().microsecondsSinceEpoch}.jpg');
    final outFile = File(outPath);
    await compressedFile.copy(outPath);
    logOcr('[4/5] ✅ Enhanced file written — ${sw.elapsedMilliseconds}ms', name: 'OCR_PREPROCESS');

    // Best-effort cleanup of old preprocessed files so the temp dir
    // doesn't grow unboundedly across many scans. Failure here must never
    // break the scan itself.
    unawaited(_cleanupOldScans(tempDir, keep: outPath));

    // Cleanup the temporary file generated by the plugin to avoid disk bloat
    try {
      await compressedFile.delete();
    } on Object catch (_) {}

    sw.stop();
    logOcr('[5/5] 🏁 Preprocessing complete — total ${sw.elapsedMilliseconds}ms', name: 'OCR_PREPROCESS');
    return outFile;
  }

  Future<void> _cleanupOldScans(Directory tempDir, {required String keep}) async {
    try {
      final entries = tempDir.listSync();
      for (final entry in entries) {
        if (entry is! File) continue;
        final name = p.basename(entry.path);
        if (!name.startsWith('card_scan_') || !name.endsWith('.jpg')) continue;
        if (entry.path == keep) continue;
        try {
          await entry.delete();
        } on Object catch (_) {
          // Ignore individual delete failures (file in use, race, etc.)
        }
      }
    } on Object catch (e) {
      logOcr('⚠️ Temp cleanup failed (non-fatal): $e', name: 'OCR_PREPROCESS');
    }
  }
}
