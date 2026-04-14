import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class CardCameraPage extends StatefulWidget {
  const CardCameraPage({super.key});

  // دالة ثابتة لفتح الكاميرا
  static Future<XFile?> capture(BuildContext context) => Navigator.of(
    context,
    rootNavigator: true,
  ).push<XFile?>(MaterialPageRoute(builder: (_) => const CardCameraPage()));

  @override
  State<CardCameraPage> createState() => _CardCameraPageState();
}

class _CardCameraPageState extends State<CardCameraPage> {
  CameraController? _controller;
  bool _isLoading = true;
  String? _error;
  bool _isFlashOn = false; // حالة الفلاش

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      // طلب إذن الكاميرا - مع معالجة الأخطاء
      bool permissionGranted = false;
      try {
        final status = await Permission.camera.request();
        permissionGranted = status.isGranted;
      } catch (e) {
        // في حالة فشل permission_handler، نفترض الإذن ممنوح على الويندوز
        debugPrint('Permission handler error: $e');
        permissionGranted =
            true; // Allow on Windows where permission_handler may fail
      }

      if (!permissionGranted) {
        setState(() {
          _error = 'يرجى السماح باستخدام الكاميرا';
          _isLoading = false;
        });
        return;
      }

      debugPrint('Camera permission granted');

      // قفل الشاشة Portrait
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // الحصول على الكاميرات المتاحة
      final cameras = await availableCameras();
      debugPrint('Available cameras: ${cameras.length}');

      if (cameras.isEmpty) {
        setState(() {
          _error = 'لا توجد كاميرا متاحة';
          _isLoading = false;
        });
        return;
      }

      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      debugPrint('Using camera: ${camera.name}');

      // إعداد Controller بأعلى جودة ممكنة مع fallback آمن
      CameraController controller;
      try {
        controller = CameraController(
          camera,
          ResolutionPreset.max,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        await controller.initialize();
      } catch (_) {
        controller = CameraController(
          camera,
          ResolutionPreset.ultraHigh,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        await controller.initialize();
      }

      debugPrint('Setting camera modes...');
      // تفعيل التركيز التلقائي المستمر لأفضل وضوح
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);

      // تفعيل ميزات إضافية لتحسين الجودة (إن وجدت)
      try {
        // محاولة قفل البياض الأبيض للحصول على ألوان أفضل
        await controller.lockCaptureOrientation();
      } catch (e) {
        debugPrint('Some advanced features not available: $e');
      }

      if (!mounted) {
        debugPrint('Widget not mounted, disposing controller');
        await controller.dispose();
        return;
      }

      debugPrint('Camera ready!');
      setState(() {
        _controller = controller;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Camera setup error: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _error = 'خطأ في تشغيل الكاميرا: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      // تفعيل الفلاش مؤقتاً إذا كان مفعلاً
      // if (_isFlashOn) {
      //   await controller.setFlashMode(FlashMode.torch);
      // }

      // الانتظار قليلاً للتركيز والتعرض المثالي
      // await Future.delayed(const Duration(milliseconds: 100));

      // التقاط الصورة بأعلى جودة
      final XFile image = await controller.takePicture();

      // // إطفاء الفلاش بعد التصوير
      // if (_isFlashOn) {
      //   await controller.setFlashMode(FlashMode.off);
      // }

      // قراءة الصورة وتحسينها
      final File imageFile = File(image.path);
      final imageBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        if (mounted) {
          Navigator.of(context).pop(image);
        }
        return;
      }

      // حساب حجم المربع في الصورة الفعلية
      final imageWidth = originalImage.width;
      final imageHeight = originalImage.height;

      // استخدام أصغر بعد لضمان المربع
      final minDimension = imageWidth < imageHeight ? imageWidth : imageHeight;
      final cropSize = (minDimension * 0.92).toInt();

      // مركز الصورة
      final cropX = (imageWidth - cropSize) ~/ 2;
      final cropY = (imageHeight - cropSize) ~/ 2;

      // قص الصورة للمربع فقط
      img.Image croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropSize,
        height: cropSize,
      );

      // تحسين جودة الصورة
      croppedImage = _enhanceImage(croppedImage);

      // img.encodeJpg يستخدم جودة 100% افتراضيا
      final croppedBytes = img.encodeJpg(croppedImage);
      await imageFile.writeAsBytes(croppedBytes);

      debugPrint('✅ Image cropped and enhanced: ${cropSize}x$cropSize');

      if (mounted) {
        Navigator.of(context).pop(image);
      }
    } catch (e) {
      debugPrint('Error taking/cropping picture: $e');
      // في حالة فشل القص، نرجع الصورة الأصلية
      try {
        final XFile image = await controller.takePicture();
        if (mounted) {
          Navigator.of(context).pop(image);
        }
      } catch (e2) {
        debugPrint('Error in fallback: $e2');
      }
    }
  }

  // دالة لتحسين جودة الصورة
  img.Image _enhanceImage(img.Image image) {
    // تعزيز بسيط فقط بدون threshold قوي حتى لا نفقد تفاصيل السيريال أسفل الكارت
    final enhanced = img.adjustColor(
      image,
      contrast: 1.25,
      brightness: 1.05,
      saturation: 1.05,
    );

    return img.contrast(enhanced, contrast: 130);
  }

  Future<void> _setFocusPoint(Offset point) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      await controller.setFocusPoint(point);
      await controller.setExposurePoint(point);
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);
    } catch (e) {
      debugPrint('Error setting focus: $e');
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });

      // تفعيل أو إطفاء الفلاش
      await controller.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Error toggling flash: $e');
      setState(() {
        _isFlashOn = false;
      });
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
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
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
          // معاينة الكاميرا مع Tap للتركيز
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: 1 / controller.value.aspectRatio,
              child: GestureDetector(
                onTapUp: (details) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;

                  final offset = box.globalToLocal(details.globalPosition);
                  final point = Offset(
                    offset.dx / box.size.width,
                    offset.dy / box.size.height,
                  );
                  _setFocusPoint(point);
                },
                child: CameraPreview(_controller!),
              ),
            ),
          ),

          // Overlay مع مربع التحديد
          const Positioned.fill(child: _CardFrameOverlay()),

          // زر الإغلاق
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // زر الفلاش
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

          // تعليمات
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'ضع الكارت داخل المربع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'اضغط على الشاشة للتركيز • ${_isFlashOn ? "الفلاش مفعل" : "استخدم الفلاش للإضاءة"}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // زر التصوير
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.3 * 255).toInt()),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
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

// Widget للإطار المربع
class _CardFrameOverlay extends StatelessWidget {
  const _CardFrameOverlay();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _CardFramePainter());
}

class _CardFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // خلفية شفافة داكنة حول المربع
    final backgroundPaint = Paint()
      ..color = Colors.black.withAlpha((0.6 * 255).toInt())
      ..style = PaintingStyle.fill;

    // حجم المربع (Square - نفس العرض والطول)
    final squareSize = size.width * 0.85;

    final left = (size.width - squareSize) / 2;
    final top = (size.height - squareSize) / 2;

    // رسم الخلفية مع فتحة للمربع
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, squareSize, squareSize),
          const Radius.circular(20),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // رسم الإطار المربع
    final framePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, squareSize, squareSize),
      const Radius.circular(20),
    );

    canvas.drawRRect(frameRect, framePaint);

    // رسم الزوايا المميزة
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    const cornerLength = 35.0;

    // الزاوية العلوية اليسرى
    canvas
      ..drawLine(
        Offset(left, top + 20),
        Offset(left, top + 20 + cornerLength),
        cornerPaint,
      )
      ..drawLine(
        Offset(left + 20, top),
        Offset(left + 20 + cornerLength, top),
        cornerPaint,
      )
      // الزاوية العلوية اليمنى
      ..drawLine(
        Offset(left + squareSize, top + 20),
        Offset(left + squareSize, top + 20 + cornerLength),
        cornerPaint,
      )
      ..drawLine(
        Offset(left + squareSize - 20, top),
        Offset(left + squareSize - 20 - cornerLength, top),
        cornerPaint,
      )
      // الزاوية السفلية اليسرى
      ..drawLine(
        Offset(left, top + squareSize - 20),
        Offset(left, top + squareSize - 20 - cornerLength),
        cornerPaint,
      )
      ..drawLine(
        Offset(left + 20, top + squareSize),
        Offset(left + 20 + cornerLength, top + squareSize),
        cornerPaint,
      )
      // الزاوية السفلية اليمنى
      ..drawLine(
        Offset(left + squareSize, top + squareSize - 20),
        Offset(left + squareSize, top + squareSize - 20 - cornerLength),
        cornerPaint,
      )
      ..drawLine(
        Offset(left + squareSize - 20, top + squareSize),
        Offset(left + squareSize - 20 - cornerLength, top + squareSize),
        cornerPaint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
