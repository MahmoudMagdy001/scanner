import 'dart:developer' as developer;
import 'dart:io';

import 'package:qrscanner/core/ocr/async_lock.dart';
import 'package:qrscanner/core/ocr/card_scan_ocr_result.dart';
import 'package:qrscanner/core/ocr/image_preprocessor.dart';
import 'package:qrscanner/core/ocr/mistral_ocr_engine.dart';

// Barrel exports — existing `import 'card_scan_ocr_service.dart'` keeps working.
export 'async_lock.dart';
export 'card_digit_extractor.dart';
export 'card_scan_ocr_result.dart';
export 'image_preprocessor.dart';
export 'mistral_ocr_engine.dart';

/// On-device preprocessing + OCR pipeline for STC recharge cards.
class CardScanOcrService {
  CardScanOcrService({required MistralOcrEngine pinOcrEngine, ImagePreprocessor? preprocessor})
    : _pinEngine = pinOcrEngine,
      _preprocessor = preprocessor ?? const ImagePreprocessor();

  final MistralOcrEngine _pinEngine;
  final ImagePreprocessor _preprocessor;
  final AsyncLock _scanLock = AsyncLock();

  Future<CardScanOcrResult> scan(File imageFile) => _scanLock.synchronized(() => _scanInternal(imageFile));

  Future<CardScanOcrResult> _scanInternal(File imageFile) async {
    var workingImage = imageFile;

    try {
      workingImage = await _preprocessor.enhance(imageFile);
    } on Object catch (e) {
      // Preprocessing is best-effort — fall back to the original image
      // instead of failing the whole scan.
      developer.log('Image preprocessing failed, using original image: $e', name: 'OCR_SERVICE');
    }

    final result = await _pinEngine.recognizeCard(workingImage);

    return CardScanOcrResult(
      pin: result?.pin,
      serial: result?.serial,
      pinConfidence: result?.pin != null ? 0.9 : 0.0,
      serialConfidence: result?.serial != null ? 0.9 : 0.0,
      pinDetected: result?.pin != null,
      serialDetected: result?.serial != null,
      // Low-confidence, near-miss values — never auto-filled, only shown so
      // the user can confirm/fix the specific unclear digit (marked '•')
      // instead of retyping the whole PIN/Serial from scratch.
      pinGuess: result?.pinGuess,
      serialGuess: result?.serialGuess,
      workingImage: workingImage,
    );
  }
}
