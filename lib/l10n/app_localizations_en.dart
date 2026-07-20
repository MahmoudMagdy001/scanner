// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Housing System';

  @override
  String get cardScannerManagement => 'Card Scanner & Management';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get scanCard => 'Scan Card';

  @override
  String get startNewScan => 'Start a new scan';

  @override
  String get savedScans => 'Saved Scans';

  @override
  String get viewHistory => 'View history';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataDesc => 'Permanently delete all scan records';

  @override
  String get clearDataConfirmTitle => 'Clear All Data';

  @override
  String get clearDataConfirmDesc =>
      'Are you sure you want to clear all saved scan data? This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get allDataCleared => 'All saved data has been cleared.';

  @override
  String get selectCardType => 'Select Card Type';

  @override
  String get availableTypes => 'Available Types';

  @override
  String get noCardTypesAvailable =>
      'No card types available.\nPlease check your server connection.';

  @override
  String get errorConnecting => 'Error connecting to server.';

  @override
  String get noInternet => 'No internet connection available.';

  @override
  String get serviceUnavailable => 'Service Unavailable';

  @override
  String get appDisabledMessage =>
      'The application is currently disabled.\nPlease contact the administrator or developer to activate the service.';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get supportDetails => 'Support Details';

  @override
  String get supportEmail => 'Support Email';

  @override
  String get supportPhone => 'Support Phone';

  @override
  String get close => 'Close';
}
