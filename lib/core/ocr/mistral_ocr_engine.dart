import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:qrscanner/core/ocr/card_digit_extractor.dart';

/// Mistral OCR engine connecting to the Mistral AI OCR API.
class MistralOcrEngine {
  MistralOcrEngine({Dio? dio, CardDigitExtractor? extractor})
    : _dio =
          dio ??
          Dio(BaseOptions(connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 30))),
      _extractor = extractor ?? const CardDigitExtractor();

  final Dio _dio;
  final CardDigitExtractor _extractor;

  // ponytail: placeholder API key — move this to `--dart-define` or a secure
  // secrets manager before shipping. Hardcoded keys in source are a leak risk.
  static const String _mistralApiKey = 'TGlou8530ObxFBInO8YMdJ7DSGmkr29g';
  static const String _ocrEndpoint = 'https://api.mistral.ai/v1/ocr';

  bool _isReadableImage(File image) {
    try {
      return image.existsSync() && image.lengthSync() > 0;
    } on Object {
      return false;
    }
  }

  Future<void> dispose() async {}

  /// Recognizes both PIN (14 digits) and Serial (12 digits) from a full card
  /// image using Mistral OCR. [image] should already be preprocessed.
  Future<({String? pin, String? serial, String? pinGuess, String? serialGuess})?> recognizeCard(File image) async {
    if (!_isReadableImage(image)) return null;

    try {
      final bytes = await image.readAsBytes();
      final base64Str = base64Encode(bytes);
      final extension = p.extension(image.path).toLowerCase();
      final mimeType = extension == '.png' ? 'image/png' : 'image/jpeg';
      final dataUrl = 'data:$mimeType;base64,$base64Str';

      developer.log('MistralOCR recognizeCard posting to: $_ocrEndpoint', name: 'OCR_ENGINE');
      final response = await _dio.post<Map<String, dynamic>>(
        _ocrEndpoint,
        data: {
          'model': 'mistral-ocr-latest',
          'document': {'type': 'image_url', 'image_url': dataUrl},
        },
        options: Options(headers: {'Authorization': 'Bearer $_mistralApiKey', 'Content-Type': 'application/json'}),
      );

      final data = response.data;
      if (data == null) return null;

      final pages = data['pages'] as List<dynamic>? ?? const [];

      String? pin;
      String? serial;
      String? pinGuess;
      String? serialGuess;

      for (final page in pages) {
        final pageMap = page as Map<String, dynamic>;
        final rawMarkdown = pageMap['markdown'] as String? ?? '';

        developer.log('MistralOCR markdown output:\n$rawMarkdown', name: 'OCR_ENGINE');

        final result = _extractor.extractFromMarkdown(rawMarkdown);
        pin ??= result.pin;
        serial ??= result.serial;
        pinGuess ??= result.pinGuess;
        serialGuess ??= result.serialGuess;

        if (pin != null && serial != null) break;
      }

      return (
        pin: pin,
        serial: serial,
        pinGuess: pin == null ? pinGuess : null,
        serialGuess: serial == null ? serialGuess : null,
      );
    } on DioException catch (e) {
      developer.log('MistralOCR recognizeCard DioError: ${e.message}, response: ${e.response}', name: 'OCR_ENGINE');
      return null;
    } on Object catch (e) {
      developer.log('MistralOCR recognizeCard generic error: $e', name: 'OCR_ENGINE');
      return null;
    }
  }
}

/// Builds OCR engines tuned for speed vs accuracy per field.
class OcrEngineFactory {
  OcrEngineFactory._();

  /// PIN: MistralOCR.
  static MistralOcrEngine createPinEngine() => MistralOcrEngine();
}
