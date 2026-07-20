import 'dart:io';

class CardScanOcrResult {
  const CardScanOcrResult({
    required this.pin,
    required this.serial,
    required this.pinConfidence,
    required this.serialConfidence,
    required this.pinDetected,
    required this.serialDetected,
    required this.workingImage,
    this.pinGuess,
    this.serialGuess,
  });

  final String? pin;
  final String? serial;
  final double pinConfidence;
  final double serialConfidence;
  final bool pinDetected;
  final bool serialDetected;
  final File workingImage;

  /// Best-effort candidate when [pin] couldn't be confirmed — contains '•'
  /// where a digit was unreadable. Present to the user for manual
  /// confirmation only; never treat as a final value.
  final String? pinGuess;

  /// Same idea as [pinGuess], for the serial number.
  final String? serialGuess;

  bool get needsManualReview =>
      (pinDetected == false && pinGuess != null) || (serialDetected == false && serialGuess != null);
}
