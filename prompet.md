Review my OCR pipeline files in Flutter (mistral_ocr_engine.dart,
image_preprocessor.dart, dio_helper.dart, card_scan_ocr_service.dart)
and apply the following speed optimizations to reduce total scan time
(upload + server processing), while keeping PIN/Serial digit
recognition accuracy acceptable:

## Image size / preprocessing

1. **Lower the target resolution in ImagePreprocessorConfig**
   Change minLongestSide from 3600 to ~1200-1400, and maxLongestSide
   from 4000 to ~1800-2000. Printed dot-matrix digits don't need
   4000px — this range should stay well within OCR-readable quality
   while cutting file size significantly. Make this configurable via
   named constants at the top of the file so it's easy to tune later
   based on real-world accuracy testing.

2. **Consider dropping the forced upscale for already-adequate images**
   Currently any image below minLongestSide gets upscaled, which can
   inflate file size without adding real detail. Evaluate whether
   upscale should only kick in below a lower floor (e.g. 800px) rather
   than 3600px, since upscaling a decent photo doesn't recover missing
   detail.

3. **Tune JPEG quality**
   Test jpegQuality in the 75-85 range instead of 92. For printed
   text/digits (not photographic detail), this range is usually
   visually/functionally lossless for OCR but meaningfully smaller in
   file size. Add a comment explaining the accuracy/size tradeoff so
   future changes are deliberate.

4. **Optional: auto-crop to the relevant card region**
   If feasible, explore auto-cropping to just the scratch-panel/serial
   area (rather than uploading the full card) using bounding-box
   detection, since the extractor already knows this area is what
   matters. This is the single biggest potential size reduction — flag
   feasibility and complexity rather than implementing blindly if it
   requires new dependencies.

## Network / client-side

5. **Disable logging interceptor in release builds**
   In DioHelper, wrap the InterceptorsWrapper with a kDebugMode check
   from foundation.dart, so developer.log (especially
   JsonEncoder.withIndent on large responses) doesn't run in production.

2. **Move base64 encoding off the main isolate**
   In MistralOcrEngine.recognizeCard, move base64Encode(bytes) into
   compute() so encoding doesn't block the UI thread, especially for
   larger preprocessed images.

3. **Confirm Dio instance reuse**
   Make sure MistralOcrEngine reuses a single Dio instance across
   requests rather than creating a new one per call to
   createPinEngine(), so TCP/TLS connections can be kept alive.

4. **Add HTTP/2 support if available**
   Evaluate adding the dio_http2_adapter package for improved
   connection efficiency.

5. **Retry logic with backoff for transient failures only**
   Add up to 2 retries with short backoff (500ms, 1500ms) for timeout/
   connection errors — not for API-level errors like 400/401.

## API request tuning

10. **Check Mistral OCR API request parameters**
    Look for parameters like include_image_base64 in the request body
    or response that might be returning unnecessary extra data (e.g.
    base64 of extracted page images), and remove/disable them to
    shrink the response payload.

## Measurement

11. **Add granular timing**
    Add a timestamp right before dio.post and another as soon as the
    first byte is received, to separate network upload/latency time
    from server-side model processing time. Log this clearly so we can
    see, after these changes, how much of the remaining time is
    actually within our control vs. inherent to Mistral's server-side
    inference.

Keep each change as a separate, clearly labeled diff/PR so I can test
accuracy after each one (especially the resolution/quality changes in
items 1-3, which need real-device validation against actual cards
before merging).
