import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrscanner/core/appStorage/app_storage.dart';
import 'package:qrscanner/core/di/injection_container.dart';
import 'package:qrscanner/core/dioHelper/dio_helper.dart';
import 'package:qrscanner/core/router/app_startup.dart';
import 'package:qrscanner/core/router/router.dart';
import 'package:qrscanner/core/theme/app_theme.dart';
import 'package:qrscanner/features/app_disabled_view.dart';
import 'package:qrscanner/firebase_options.dart';
import 'package:qrscanner/l10n/app_localizations.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)..badCertificateCallback = (cert, host, port) => true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  ); // ponytail: minimal system chrome setup

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on Object catch (_) {
    // Firebase initialization failed
  }

  HttpOverrides.global = MyHttpOverrides();

  try {
    await AppStorage.init();
    await initDependencies();
    DioHelper.initBaseUrl();

    runApp(const MyApp());
  } on Object catch (_) {
    // App initialization failed
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) => StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('app_control').doc('status').snapshots(),
      builder: (context, snapshot) {
        // Wait state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: const Scaffold(body: Center(child: CircularProgressIndicator())),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light, // ponytail: force light theme
            locale: const Locale('en'), // ponytail: force English locale
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), // ponytail: force no font scale
              child: child!,
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return MaterialApp(
            home: const Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Error connecting to server.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light, // ponytail: force light theme
            locale: const Locale('en'), // ponytail: force English locale
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), // ponytail: force no font scale
              child: child!,
            ),
          );
        }

        // Data available state
        final isAppEnabled = (snapshot.data?.get('enabled') as bool?) ?? false;

        if (!isAppEnabled) {
          return MaterialApp(
            home: const AppDisabledView(),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light, // ponytail: force light theme
            locale: const Locale('en'), // ponytail: force English locale
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), // ponytail: force no font scale
              child: child!,
            ),
          );
        }

        // App enabled
        return MaterialApp(
          home: AppStartup.resolveInitialScreen(),
          onGenerateRoute: onGenerateRoute,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light, // ponytail: force light theme
          locale: const Locale('en'), // ponytail: force English locale
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), // ponytail: force no font scale
            child: child!,
          ),
        );
      },
    ),
  );
}
