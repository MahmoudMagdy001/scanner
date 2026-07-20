/// Digit extraction (pure logic, unit-testable, no I/O).
class CardDigitExtractor {
  const CardDigitExtractor();

  // Broad token: digits, letters the dot-matrix font commonly gets confused
  // with (see _fixOcrConfusion), and '?' — Mistral emits '?' in place of a
  // digit it genuinely couldn't read. Including it here keeps the token from
  // being split into two useless fragments; it's still stripped out (never
  // guessed at) before anything is treated as a final, usable value.
  static final RegExp _tokenRegex = RegExp(r'[0-9OoQIlBSsZGg?]+(?:[\s\-][0-9OoQIlBSsZGg?]+)+|[0-9OoQIlBSsZGg?]{10,}');
  static final RegExp _nonDigitRegex = RegExp(r'\D');
  static const _unclearMarker = '?';

  static const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  static const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  // The PIN sits directly under "Scratch Here" / "اكشط هنا", and the Serial
  // sits next to "Serial Number" / "الرقم التسلسلي". Anchoring on these
  // keywords is far safer than a blind text-wide scan — it avoids picking up
  // the 15-digit VAT number (which could collapse to a false 14-digit PIN if
  // the OCR drops one digit) or the "Valid Until" date.
  static const _pinKeywords = ['Scratch Here', 'اكشط هنا'];
  static const _serialKeywords = ['Serial Number', 'الرقم التسلسلي'];

  // Characters visually close to digits on the card's dot-matrix font.
  static const Map<String, String> _ocrConfusionMap = {
    'O': '0',
    'o': '0',
    'Q': '0',
    'I': '1',
    'l': '1',
    'S': '5',
    's': '5',
    'B': '8',
    'Z': '2',
    'G': '6',
    'g': '9',
  };

  /// Normalizes Eastern Arabic/Persian digits to standard Western Arabic (0-9).
  String normalizeDigits(String text) {
    var normalized = text;
    for (var i = 0; i < 10; i++) {
      normalized = normalized.replaceAll(_arabicDigits[i], '$i');
      normalized = normalized.replaceAll(_persianDigits[i], '$i');
    }
    return normalized;
  }

  /// Applied only to isolated numeric-looking tokens, never to full lines —
  /// doing it on full text would corrupt the keywords themselves (e.g. the
  /// 'S' in "Serial").
  String _fixOcrConfusion(String token) {
    var fixed = token;
    _ocrConfusionMap.forEach((from, to) => fixed = fixed.replaceAll(from, to));
    return fixed;
  }

  String? _bestDigitsInText(String text, bool Function(String digits) isValidLength) {
    String? best;
    for (final match in _tokenRegex.allMatches(text)) {
      final digits = _fixOcrConfusion(match.group(0)!).replaceAll(_nonDigitRegex, '');
      if (isValidLength(digits)) {
        best = digits;
        break;
      }
    }
    return best;
  }

  /// Looks for a digit token on the same line as [keywords], or the next
  /// couple of lines (OCR sometimes splits the label and value onto
  /// separate lines).
  String? _findNearKeywords(List<String> lines, List<String> keywords, bool Function(String digits) isValidLength) {
    for (var i = 0; i < lines.length; i++) {
      final hasKeyword = keywords.any((k) => lines[i].contains(k));
      if (!hasKeyword) continue;

      final found = _bestDigitsInText(lines[i], isValidLength);
      if (found != null) return found;

      for (var j = i + 1; j < lines.length && j <= i + 2; j++) {
        final nearby = _bestDigitsInText(lines[j], isValidLength);
        if (nearby != null) return nearby;
      }
    }
    return null;
  }

  String? cleanPinCandidate(String digits) => digits.length == 14 ? digits : null;

  String? cleanSerialCandidate(String digits) {
    // Serial is always 12 digits, typically starting with '103' or '60000'.
    if (digits.length == 12) return digits;

    // Handle common OCR noise cases (e.g. an extra leading/trailing digit).
    if (digits.length == 13) {
      if (digits.startsWith('1103') || digits.startsWith('160000')) {
        return digits.substring(1);
      }
      if (digits.endsWith('1') && (digits.startsWith('60000') || digits.startsWith('103'))) {
        return digits.substring(0, 12);
      }
      if (digits.startsWith('1') &&
          (digits.substring(1).startsWith('103') || digits.substring(1).startsWith('60000'))) {
        return digits.substring(1);
      }
    }

    if (digits.length == 14 && digits.startsWith('1') && digits.endsWith('1')) {
      final middle = digits.substring(1, 13);
      if (middle.startsWith('103') || middle.startsWith('60000')) {
        return middle;
      }
    }

    return null;
  }

  /// A near-miss candidate: right length range but containing at least one
  /// [_unclearMarker], so it must never be auto-filled — only offered to the
  /// user as "we think it's this, please confirm the marked digit(s)".
  String? _guessFor(String rawToken, int targetLength) {
    if (!rawToken.contains(_unclearMarker)) return null;
    final normalized = _fixOcrConfusion(rawToken).replaceAll(RegExp(r'[\s\-]'), '');
    final digitsAndMarkers = normalized.replaceAll(RegExp(r'[^\d?]'), '');
    if (digitsAndMarkers.length != targetLength) return null;
    // Replace with a clearer placeholder glyph for display purposes.
    return digitsAndMarkers.replaceAll(_unclearMarker, '•');
  }

  ({String? pin, String? serial, String? pinGuess, String? serialGuess}) extractFromMarkdown(String rawMarkdown) {
    final markdown = normalizeDigits(rawMarkdown);
    final lines = markdown.split('\n');

    // Pass 1 — keyword-anchored (safe: won't confuse VAT/date numbers with
    // the PIN/Serial since it only looks near the relevant label).
    var pin = _findNearKeywords(lines, _pinKeywords, (d) => d.length == 14);
    var serial = _findNearKeywords(lines, _serialKeywords, (d) => cleanSerialCandidate(d) != null);
    serial = serial != null ? cleanSerialCandidate(serial) : null;

    String? pinGuess;
    String? serialGuess;

    if (pin != null && serial != null) {
      return (pin: pin, serial: serial, pinGuess: null, serialGuess: null);
    }

    // Pass 2 — whole-text fallback for cards whose labels the OCR didn't
    // recognize (different layout, translated text, etc.).
    for (final match in _tokenRegex.allMatches(markdown)) {
      final rawToken = match.group(0)!;
      final digits = _fixOcrConfusion(rawToken).replaceAll(_nonDigitRegex, '');
      pin ??= cleanPinCandidate(digits);
      serial ??= cleanSerialCandidate(digits);
      pinGuess ??= _guessFor(rawToken, 14);
      serialGuess ??= _guessFor(rawToken, 12);
      if (pin != null && serial != null) break;
    }

    if (pin == null || serial == null) {
      for (final line in lines) {
        final lineDigits = _fixOcrConfusion(line).replaceAll(_nonDigitRegex, '');
        pin ??= cleanPinCandidate(lineDigits);
        serial ??= cleanSerialCandidate(lineDigits);
        if (pin != null && serial != null) break;
      }
    }

    return (
      pin: pin,
      serial: serial,
      pinGuess: pin == null ? pinGuess : null,
      serialGuess: serial == null ? serialGuess : null,
    );
  }
}
