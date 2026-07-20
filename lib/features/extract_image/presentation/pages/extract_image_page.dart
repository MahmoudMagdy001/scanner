import 'dart:async';
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrscanner/core/theme/app_colors.dart';
import 'package:qrscanner/core/theme/app_text_styles.dart';
import 'package:qrscanner/core/widgets/snack_bar.dart';
import 'package:qrscanner/features/extract_image/presentation/bloc/extract_image_bloc.dart';
// Import refactored smaller widgets
import 'package:qrscanner/features/extract_image/presentation/widgets/camera_button_widget.dart';
import 'package:qrscanner/features/extract_image/presentation/widgets/fields_card_widget.dart';
import 'package:qrscanner/features/extract_image/presentation/widgets/history_count_widget.dart';
import 'package:qrscanner/features/extract_image/presentation/widgets/image_preview_widget.dart';
import 'package:qrscanner/features/extract_image/presentation/widgets/save_button_widget.dart';

class ExtractImagePage extends StatefulWidget {
  const ExtractImagePage({required this.categoryId, super.key, this.scanType});
  final String? scanType;
  final int categoryId;

  @override
  State<ExtractImagePage> createState() => _ExtractImagePageState();
}

class _ExtractImagePageState extends State<ExtractImagePage> {
  late final TextEditingController _pinController;
  late final TextEditingController _serialController;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _serialController = TextEditingController();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _captureImage(BuildContext context) async {
    // ponytail: use cunning_document_scanner for automatic edge detection and cropping
    try {
      final images = await CunningDocumentScanner.getPictures();
      if (images == null || images.isEmpty) return;

      final sourceFile = File(images.first);
      if (!sourceFile.existsSync()) {
        if (context.mounted) {
          showSnackBar('Failed to save image', color: Colors.red);
        }
        return;
      }

      if (context.mounted) {
        context.read<ExtractImageBloc>().add(SetImageEvent(sourceFile));
        context.read<ExtractImageBloc>().add(const ProcessImageEvent());
      }
    } on Object catch (e) {
      if (context.mounted) {
        showSnackBar('Failed to scan card: $e', color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<ExtractImageBloc, ExtractImageState>(
    listener: (context, state) {
      if (state is ScanResultLoaded) {
        _pinController.text = formatPin4343(state.pin ?? '');
        _serialController.text = state.serial ?? '';
      }
      if (state is ScanError && state.message != null) {
        showSnackBar(state.message!, color: Colors.red);
      }
      if (state is ScanSuccess) {
        showSnackBar('Saved successfully', color: Colors.green);
        _pinController.clear();
        _serialController.clear();
        // Clear image and reset state
        context.read<ExtractImageBloc>().add(const ResetEvent());
      }
    },
    child: Scaffold(
      backgroundColor: colorBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ImagePreviewWidget(),
              SizedBox(height: 20.h),
              CameraButtonWidget(onPress: () => _captureImage(context)),
              SizedBox(height: 24.h),
              FieldsCardWidget(pinController: _pinController, serialController: _serialController),
              SizedBox(height: 24.h),
              SaveButtonWidget(
                pinController: _pinController,
                serialController: _serialController,
                categoryId: widget.categoryId,
              ),
              SizedBox(height: 20.h),
              const HistoryCountWidget(),
            ],
          ),
        ),
      ),
    ),
  );

  String _getCardAsset() {
    final type = widget.scanType?.toLowerCase() ?? '';
    // ponytail: map the type string to the local card asset image (e.g. 20, 25, 30, 50, 100)
    if (type.contains('100')) return 'assets/images/100.jpeg';
    if (type.contains('50')) return 'assets/images/50.jpeg';
    if (type.contains('30')) return 'assets/images/30.jpeg';
    if (type.contains('25')) return 'assets/images/25.jpeg';
    if (type.contains('20')) return 'assets/images/20.jpeg';

    final index = widget.categoryId;
    const fallbackList = [
      'assets/images/20.jpeg',
      'assets/images/25.jpeg',
      'assets/images/30.jpeg',
      'assets/images/50.jpeg',
      'assets/images/100.jpeg',
    ];
    return fallbackList[index % fallbackList.length];
  }

  PreferredSizeWidget _buildAppBar() {
    final assetPath = _getCardAsset();
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 24.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: colorBorder, width: 1.r),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4.r, offset: Offset(0, 2.h))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.r),
              child: Image.asset(assetPath, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 8.w),
          Text(widget.scanType ?? 'Scan Card', style: AppTextStyles.titleMedium),
        ],
      ),
      backgroundColor: colorSurface,
      foregroundColor: colorPrimary,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Divider(height: 1.h, color: colorDivider),
      ),
    );
  }
}
