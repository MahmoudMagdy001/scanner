import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:path/path.dart' as p;
import 'package:qrscanner/core/ocr/card_digit_extractor.dart';
import 'package:qrscanner/core/ocr/ocr_logger.dart';

// ponytail: HTTP/2 evaluation: Standard Dart HttpClientAdapter automatically reuses TCP/TLS connections with Keep-Alive
// for serial requests. dio_http2_adapter can be added if parallel requests are introduced in the future.

/// Mistral OCR engine connecting to the Mistral AI OCR API.
class MistralOcrEngine {
  /// Shared Dio instance across requests to keep TCP/TLS connections alive.
  static final Dio _sharedDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  MistralOcrEngine({Dio? dio, CardDigitExtractor? extractor})
    : _dio = dio ?? _sharedDio,
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

  bool _isTransientError(DioException e) {
    // Only retry connection/timeout errors, not API response status codes (e.g. 400/401)
    if (e.response != null) return false;
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        (e.type == DioExceptionType.unknown && e.error is SocketException);
  }

  Future<void> dispose() async {}

  /// Recognizes both PIN (14 digits) and Serial (12 digits) from a full card
  /// image using Mistral OCR. [image] should already be preprocessed.
  Future<({String? pin, String? serial, String? pinGuess, String? serialGuess})?> recognizeCard(File image) async {
    if (!_isReadableImage(image)) {
      logOcr('❌ Image not readable, aborting', name: 'OCR_ENGINE');
      return null;
    }

    final sw = Stopwatch()..start();

    try {
      final bytes = await image.readAsBytes();
      logOcr(
        '[1/6] ✅ Image bytes read (${(bytes.length / 1024).toStringAsFixed(1)} KB) — ${sw.elapsedMilliseconds}ms',
        name: 'OCR_ENGINE',
      );

      // Move base64 encoding off the main isolate to keep UI responsive
      final base64Str = await compute(base64Encode, bytes);
      logOcr(
        '[2/6] ✅ Base64 encoded (${(base64Str.length / 1024).toStringAsFixed(1)} KB) — ${sw.elapsedMilliseconds}ms',
        name: 'OCR_ENGINE',
      );

      final extension = p.extension(image.path).toLowerCase();
      final mimeType = extension == '.png' ? 'image/png' : 'image/jpeg';
      final dataUrl = 'data:$mimeType;base64,$base64Str';

      logOcr('[3/6] 🚀 Uploading to Mistral API...', name: 'OCR_ENGINE');

      Response<Map<String, dynamic>>? response;
      var attempt = 0;
      const maxRetries = 2;
      const backoffs = [Duration(milliseconds: 500), Duration(milliseconds: 1500)];

      while (true) {
        try {
          final swApi = Stopwatch()..start();
          int? uploadMs;

          response = await _dio.post<Map<String, dynamic>>(
            _ocrEndpoint,
            data: {
              'model': 'mistral-ocr-latest',
              'document': {'type': 'image_url', 'image_url': dataUrl},
              // Disable base64 page images in response to shrink payload size
              'include_image_base64': false,
            },
            options: Options(
              headers: {'Authorization': 'Bearer $_mistralApiKey', 'Content-Type': 'application/json'},
            ),
            onSendProgress: (sent, total) {
              if (total > 0 && sent == total && uploadMs == null) {
                uploadMs = swApi.elapsedMilliseconds;
                logOcr(
                  '  [network] ⬆️ Upload finished (${(total / 1024).toStringAsFixed(1)} KB) in ${uploadMs}ms. Waiting for server inference...',
                  name: 'OCR_ENGINE',
                );
              }
            },
          );

          final totalApiMs = swApi.elapsedMilliseconds;
          final inferenceMs = uploadMs != null ? totalApiMs - uploadMs! : null;
          logOcr(
            '[4/6] ✅ API response received — upload: ${uploadMs ?? "N/A"}ms | server inference: ${inferenceMs ?? "N/A"}ms | total API: ${totalApiMs}ms',
            name: 'OCR_ENGINE',
          );
          break;
        } on DioException catch (e) {
          if (_isTransientError(e) && attempt < maxRetries) {
            final delay = backoffs[attempt];
            attempt++;
            logOcr(
              '⚠️ Transient network error (${e.type.name}). Retrying attempt $attempt/$maxRetries in ${delay.inMilliseconds}ms...',
              name: 'OCR_ENGINE',
            );
            await Future<void>.delayed(delay);
            continue;
          }
          rethrow;
        }
      }

      final data = response.data;
      if (data == null) {
        logOcr('❌ API returned null data', name: 'OCR_ENGINE');
        return null;
      }

      final pages = data['pages'] as List<dynamic>? ?? const [];
      logOcr('[5/6] 📄 Parsing ${pages.length} page(s)...', name: 'OCR_ENGINE');

      String? pin;
      String? serial;
      String? pinGuess;
      String? serialGuess;

      for (final page in pages) {
        final pageMap = page as Map<String, dynamic>;
        final rawMarkdown = pageMap['markdown'] as String? ?? '';

        logOcr('📝 Raw markdown (${rawMarkdown.length} chars):\n$rawMarkdown', name: 'OCR_ENGINE');

        final result = _extractor.extractFromMarkdown(rawMarkdown);
        logOcr(
          '🔍 Extracted → pin: ${result.pin ?? "null"}, serial: ${result.serial ?? "null"}, pinGuess: ${result.pinGuess ?? "null"}, serialGuess: ${result.serialGuess ?? "null"}',
          name: 'OCR_ENGINE',
        );

        pin ??= result.pin;
        serial ??= result.serial;
        pinGuess ??= result.pinGuess;
        serialGuess ??= result.serialGuess;

        if (pin != null && serial != null) break;
      }

      sw.stop();
      logOcr(
        '[6/6] 🏁 Recognition complete — total ${sw.elapsedMilliseconds}ms | pin: ${pin != null ? "✅" : "❌"}, serial: ${serial != null ? "✅" : "❌"}',
        name: 'OCR_ENGINE',
      );

      return (
        pin: pin,
        serial: serial,
        pinGuess: pin == null ? pinGuess : null,
        serialGuess: serial == null ? serialGuess : null,
      );
    } on DioException catch (e) {
      sw.stop();
      logOcr('❌ DioError at ${sw.elapsedMilliseconds}ms: ${e.message}, response: ${e.response}', name: 'OCR_ENGINE');
      return null;
    } on Object catch (e) {
      sw.stop();
      logOcr('❌ Error at ${sw.elapsedMilliseconds}ms: $e', name: 'OCR_ENGINE');
      return null;
    }
  }
}

/// Builds OCR engines tuned for speed vs accuracy per field.
class OcrEngineFactory {
  OcrEngineFactory._();

  /// PIN: MistralOCR. Reuses shared Dio instance across requests.
  static MistralOcrEngine createPinEngine() => MistralOcrEngine();
}
