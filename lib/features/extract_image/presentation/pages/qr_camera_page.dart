// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class QrCameraPage extends StatefulWidget {
  const QrCameraPage({super.key});

  static Future<XFile?> capture(BuildContext context) => Navigator.of(
    context,
    rootNavigator: true,
  ).push<XFile?>(MaterialPageRoute(builder: (_) => const QrCameraPage()));

  @override
  State<QrCameraPage> createState() => _QrCameraPageState();
}

class _QrCameraPageState extends State<QrCameraPage> {
  CameraController? _controller;
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _isFlashOn = false;
  String? _error;

  final GlobalKey _previewContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _error = 'Camera permission is required.';
          _isLoading = false;
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = 'No camera available.';
          _isLoading = false;
        });
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);

      try {
        await controller.lockCaptureOrientation();
      } catch (_) {
        // Some devices do not support capture orientation lock.
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to start camera: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      _isFlashOn = !_isFlashOn;
      setState(() {});
      await controller.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (_) {
      _isFlashOn = false;
      setState(() {});
    }
  }

  Future<void> _setFocusPoint(Offset point) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      await controller.setFocusPoint(point);
      await controller.setExposurePoint(point);
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);
    } catch (_) {
      // Supported on some devices only.
    }
  }

  Future<void> _captureImage() async {
    if (_isProcessing) return;

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    _isProcessing = true;
    setState(() {});

    try {
      final imageFile = await controller.takePicture();
      final sourceFile = File(imageFile.path);
      final imageBytes = await sourceFile.readAsBytes();

      final previewBox =
          _previewContainerKey.currentContext?.findRenderObject() as RenderBox?;

      final processed = await compute(_processImage, {
        'imageBytes': imageBytes,
        'previewWidth': previewBox?.size.width,
        'previewHeight': previewBox?.size.height,
        'previewDx': previewBox?.localToGlobal(Offset.zero).dx,
        'previewDy': previewBox?.localToGlobal(Offset.zero).dy,
        'screenWidth': MediaQuery.of(context).size.width,
        'screenHeight': MediaQuery.of(context).size.height,
      });

      final dir = await getApplicationDocumentsDirectory();
      final savePath =
          '${dir.path}/qr_card_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await File(savePath).writeAsBytes(processed, flush: true);

      if (mounted) {
        Navigator.of(context).pop(XFile(savePath));
      }
    } catch (_) {
      _isProcessing = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1 / controller.value.aspectRatio,
                child: GestureDetector(
                  onTapUp: (details) {
                    final box =
                        _previewContainerKey.currentContext?.findRenderObject()
                            as RenderBox?;
                    if (box == null) return;

                    final localOffset =
                        box.globalToLocal(details.globalPosition);
                    final focusPoint = Offset(
                      (localOffset.dx / box.size.width).clamp(0.0, 1.0),
                      (localOffset.dy / box.size.height).clamp(0.0, 1.0),
                    );
                    _setFocusPoint(focusPoint);
                  },
                  child: Container(
                    key: _previewContainerKey,
                    color: Colors.black,
                    child: CameraPreview(controller),
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(child: _CardFrameOverlay()),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 32,
              ),
              onPressed: _toggleFlash,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Place the card inside the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isFlashOn
                      ? 'Flash is on'
                      : 'Tap the preview to focus before capture',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isProcessing ? null : _captureImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isProcessing ? Colors.grey : Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: _isProcessing
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<int> _processImage(Map data) {
  final raw = data['imageBytes'];
  final Uint8List bytes = raw is Uint8List
      ? raw
      : Uint8List.fromList(raw as List<int>);
  final image = img.decodeImage(bytes);

  if (image == null) return bytes;

  final previewW = data['previewWidth'] as double?;
  final previewH = data['previewHeight'] as double?;
  final dx = data['previewDx'] as double?;
  final dy = data['previewDy'] as double?;
  final screenW = data['screenWidth'] as double?;
  final screenH = data['screenHeight'] as double?;

  img.Image cropped;

  if (previewW == null ||
      previewH == null ||
      dx == null ||
      dy == null ||
      screenW == null ||
      screenH == null) {
    final size =
        (image.width < image.height ? image.width : image.height) * 0.82;
    cropped = img.copyCrop(
      image,
      x: ((image.width - size) / 2).round(),
      y: ((image.height - size) / 2).round(),
      width: size.round(),
      height: size.round(),
    );
  } else {
    final overlaySize = screenW * 0.70;
    final left = (screenW - overlaySize) / 2;
    final top = (screenH - overlaySize) / 2;

    final relLeft = left - dx;
    final relTop = top - dy;

    final scaleX = image.width / previewW;
    final scaleY = image.height / previewH;

    var cropX = (relLeft * scaleX).round();
    var cropY = (relTop * scaleY).round();
    var cropW = (overlaySize * scaleX).round();
    var cropH = (overlaySize * scaleY).round();

    final paddingX = (cropW * 0.04).round();
    final paddingY = (cropH * 0.04).round();

    cropX = (cropX - paddingX).clamp(0, image.width - 1);
    cropY = (cropY - paddingY).clamp(0, image.height - 1);
    cropW = (cropW + paddingX * 2).clamp(1, image.width - cropX);
    cropH = (cropH + paddingY * 2).clamp(1, image.height - cropY);

    cropped = img.copyCrop(
      image,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );
  }

  final enhanced = _enhanceForOcr(cropped);
  return img.encodeJpg(enhanced, quality: 95);
}

img.Image _enhanceForOcr(img.Image image) {
  var processed = image;

  if (processed.width < 1400) {
    processed = img.copyResize(
      processed,
      width: 1400,
      interpolation: img.Interpolation.cubic,
    );
  }

  processed = img.adjustColor(
    processed,
    contrast: 1.2,
    brightness: 1.03,
    saturation: 1.02,
  );
  processed = img.gaussianBlur(processed, radius: 1);

  return processed;
}

class _CardFrameOverlay extends StatelessWidget {
  const _CardFrameOverlay();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _CardFramePainter());
}

class _CardFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = Colors.black.withAlpha((0.6 * 255).toInt())
      ..style = PaintingStyle.fill;

    final square = size.width * 0.70;
    final left = (size.width - square) / 2;
    final top = (size.height - square) / 2;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, square, square),
          const Radius.circular(20),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, bg);

    final frame = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, square, square),
        const Radius.circular(20),
      ),
      frame,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
