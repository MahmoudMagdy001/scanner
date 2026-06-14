import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageIsolateHelper {
  static Future<File?> compressImageInIsolate({
    required String imagePath,
    int targetWidth = 2000,
  }) async {
    try {
      final params = _CompressionParams(
        imagePath: imagePath,
        targetWidth: targetWidth,
      );
      return await compute(_compressImage, params);
    } catch (_) {
      return null;
    }
  }

  static Future<({int width, int height})?> getImageDimensionsInIsolate({
    required String imagePath,
  }) async {
    try {
      final result = await compute(_readImageDimensions, imagePath);
      if (result == null) return null;
      return (width: result['width']!, height: result['height']!);
    } catch (_) {
      return null;
    }
  }

  static Future<PreparedScanAssets?> prepareScanAssetsInIsolate({
    required String imagePath,
    required ScanCropBox pinCropBox,
    required ScanCropBox serialCropBox,
  }) async {
    try {
      final result = await compute(_prepareScanAssets, {
        'imagePath': imagePath,
        'pinCropBox': pinCropBox.toMap(),
        'serialCropBox': serialCropBox.toMap(),
      });
      if (result == null) return null;
      return PreparedScanAssets.fromMap(result);
    } catch (_) {
      return null;
    }
  }

  static Future<File?> _compressImage(_CompressionParams params) async {
    try {
      final imageFile = File(params.imagePath);
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return null;

      final resized = img.copyResize(decodedImage, width: params.targetWidth);
      final compressedBytes = img.encodeJpg(resized, quality: 90);
      final tempPath =
          '${imageFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(compressedBytes);
      return tempFile;
    } catch (_) {
      return null;
    }
  }

  static Map<String, int>? _readImageDimensions(String imagePath) {
    try {
      final bytes = File(imagePath).readAsBytesSync();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return null;
      return {'width': decodedImage.width, 'height': decodedImage.height};
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _prepareScanAssets(Map<String, dynamic> params) {
    try {
      final imagePath = params['imagePath'] as String?;
      final pinCropData = params['pinCropBox'] as Map<Object?, Object?>?;
      final serialCropData = params['serialCropBox'] as Map<Object?, Object?>?;
      if (imagePath == null || pinCropData == null || serialCropData == null) {
        return null;
      }

      final imageFile = File(imagePath);
      final pinCropBox = ScanCropBox.fromMap(pinCropData.cast<String, int>());
      final serialCropBox = ScanCropBox.fromMap(
        serialCropData.cast<String, int>(),
      );
      final bytes = imageFile.readAsBytesSync();
      final sourceImage = img.decodeImage(bytes);
      if (sourceImage == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final pinBasePath = '${imageFile.parent.path}/pin_$timestamp.jpg';
      final serialBasePath = '${imageFile.parent.path}/serial_$timestamp.jpg';

      final pinBaseImage = _buildBaseCrop(sourceImage, pinCropBox);
      final serialBaseImage = _buildBaseCrop(sourceImage, serialCropBox);

      File(
        pinBasePath,
      ).writeAsBytesSync(img.encodeJpg(pinBaseImage, quality: 90));
      File(
        serialBasePath,
      ).writeAsBytesSync(img.encodeJpg(serialBaseImage, quality: 90));

      final pinVariantPaths = _createVariants(
        baseImage: pinBaseImage,
        parentPath: imageFile.parent.path,
        prefix: 'pin_variant_$timestamp',
      );
      final serialVariantPaths = _createVariants(
        baseImage: serialBaseImage,
        parentPath: imageFile.parent.path,
        prefix: 'serial_variant_$timestamp',
      );

      return PreparedScanAssets(
        pinBasePath: pinBasePath,
        serialBasePath: serialBasePath,
        pinVariantPaths: pinVariantPaths,
        serialVariantPaths: serialVariantPaths,
      ).toMap();
    } catch (_) {
      return null;
    }
  }

  static img.Image _buildBaseCrop(img.Image source, ScanCropBox cropBox) {
    var cropped = img.copyCrop(
      source,
      x: cropBox.left,
      y: cropBox.top,
      width: cropBox.width,
      height: cropBox.height,
    );

    cropped = img.copyResize(
      cropped,
      width: (cropped.width * 2).clamp(1000, 2400),
      interpolation: img.Interpolation.cubic,
    );
    cropped = img.grayscale(cropped);
    cropped = img.adjustColor(cropped, contrast: 1.8, brightness: 1.08);
    return cropped;
  }

  static List<String> _createVariants({
    required img.Image baseImage,
    required String parentPath,
    required String prefix,
  }) {
    final variants = <img.Image>[
      _prepareVariant(baseImage, contrast: 1.7, brightness: 1.05),
      _prepareVariant(
        baseImage,
        contrast: 2.1,
        brightness: 1.12,
        threshold: 145,
      ),
      _prepareVariant(
        baseImage,
        contrast: 2.4,
        brightness: 1.18,
        threshold: 120,
      ),
      _prepareVariant(
        baseImage,
        contrast: 1.9,
        brightness: 1.08,
        threshold: 165,
      ),
    ];

    final paths = <String>[];
    for (var i = 0; i < variants.length; i++) {
      final path = '$parentPath/${prefix}_$i.jpg';
      File(path).writeAsBytesSync(img.encodeJpg(variants[i], quality: 90));
      paths.add(path);
    }
    return paths;
  }

  static img.Image _prepareVariant(
    img.Image source, {
    required double contrast,
    required double brightness,
    int? threshold,
  }) {
    var processed = img.copyResize(
      source,
      width: source.width.clamp(1200, 2400),
      interpolation: img.Interpolation.cubic,
    );
    processed = img.grayscale(processed);
    processed = img.adjustColor(
      processed,
      contrast: contrast,
      brightness: brightness,
    );
    processed = img.gaussianBlur(processed, radius: 1);

    if (threshold != null) {
      processed = _binarizeImage(processed, threshold: threshold);
    }

    return processed;
  }

  static img.Image _binarizeImage(img.Image source, {required int threshold}) {
    final result = img.Image(width: source.width, height: source.height);
    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        final pixel = source.getPixel(x, y);
        final luminance = pixel.luminance;
        final value = luminance < threshold ? 0 : 255;
        result.setPixel(x, y, img.ColorRgb8(value, value, value));
      }
    }
    return result;
  }
}

class PreparedScanAssets {
  const PreparedScanAssets({
    required this.pinBasePath,
    required this.serialBasePath,
    required this.pinVariantPaths,
    required this.serialVariantPaths,
  });

  factory PreparedScanAssets.fromMap(Map<String, dynamic> map) =>
      PreparedScanAssets(
        pinBasePath: map['pinBasePath'] as String,
        serialBasePath: map['serialBasePath'] as String,
        pinVariantPaths: List<String>.from(map['pinVariantPaths'] as List),
        serialVariantPaths: List<String>.from(
          map['serialVariantPaths'] as List,
        ),
      );

  final String pinBasePath;
  final String serialBasePath;
  final List<String> pinVariantPaths;
  final List<String> serialVariantPaths;

  Map<String, dynamic> toMap() => {
    'pinBasePath': pinBasePath,
    'serialBasePath': serialBasePath,
    'pinVariantPaths': pinVariantPaths,
    'serialVariantPaths': serialVariantPaths,
  };
}

class ScanCropBox {
  const ScanCropBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  factory ScanCropBox.fromMap(Map<String, int> map) => ScanCropBox(
    left: map['left'] ?? 0,
    top: map['top'] ?? 0,
    width: map['width'] ?? 1,
    height: map['height'] ?? 1,
  );

  final int left;
  final int top;
  final int width;
  final int height;

  Map<String, int> toMap() => {
    'left': left,
    'top': top,
    'width': width,
    'height': height,
  };
}

class _CompressionParams {
  const _CompressionParams({
    required this.imagePath,
    required this.targetWidth,
  });

  final String imagePath;
  final int targetWidth;
}
