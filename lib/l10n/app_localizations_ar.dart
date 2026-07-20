// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نظام الإسكان';

  @override
  String get cardScannerManagement => 'ماسح البطاقات وإدارتها';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get scanCard => 'مسح البطاقة';

  @override
  String get startNewScan => 'بدء مسح جديد';

  @override
  String get savedScans => 'المسوحات المحفوظة';

  @override
  String get viewHistory => 'عرض السجل';

  @override
  String get dataManagement => 'إدارة البيانات';

  @override
  String get clearAllData => 'مسح جميع البيانات';

  @override
  String get clearAllDataDesc => 'حذف جميع سجلات المسح نهائياً';

  @override
  String get clearDataConfirmTitle => 'مسح جميع البيانات';

  @override
  String get clearDataConfirmDesc =>
      'هل أنت متأكد من رغبتك في مسح جميع بيانات المسح المحفوظة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get clear => 'مسح';

  @override
  String get allDataCleared => 'تم مسح جميع البيانات المحفوظة.';

  @override
  String get selectCardType => 'اختر نوع البطاقة';

  @override
  String get availableTypes => 'الأنواع المتاحة';

  @override
  String get noCardTypesAvailable =>
      'لا توجد أنواع بطاقات متاحة.\nيرجى التحقق من اتصالك بالخادم.';

  @override
  String get errorConnecting => 'خطأ في الاتصال بالخادم.';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get serviceUnavailable => 'الخدمة غير متوفرة';

  @override
  String get appDisabledMessage =>
      'التطبيق معطل حالياً.\nيرجى التواصل مع مسؤول النظام أو المطور لتفعيل الخدمة.';

  @override
  String get contactSupport => 'الاتصال بالدعم';

  @override
  String get supportDetails => 'تفاصيل الدعم';

  @override
  String get supportEmail => 'البريد الإلكتروني للدعم';

  @override
  String get supportPhone => 'هاتف الدعم';

  @override
  String get close => 'إغلاق';
}
