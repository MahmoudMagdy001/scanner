import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/appStorage/app_storage.dart';
import 'core/dioHelper/dio_helper.dart';
import 'core/router/router.dart';
import 'features/app_disabled_view.dart';
import 'features/settings/presentation/settings_view.dart';
import 'firebase_options.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase initialization failed
  }

  HttpOverrides.global = MyHttpOverrides();

  try {
    await AppStorage.init();
    await initDependencies();
    DioHelper.initBaseUrl();

    runApp(const MyApp());
  } catch (e) {
    // App initialization failed
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('app_control')
        .doc('status')
        .snapshots(),
    builder: (context, snapshot) {
      // Wait state
      if (snapshot.connectionState == ConnectionState.waiting) {
        return MaterialApp(
          home: const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          debugShowCheckedModeBanner: false,
          // Apply new theme right away
          theme: AppTheme.lightTheme,
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
        );
      }

      // Data available state
      final bool isAppEnabled = snapshot.data?.get('enabled') ?? false;

      if (!isAppEnabled) {
        return MaterialApp(
          home: const AppDisabledView(),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
        );
      }

      // App enabled
      return MaterialApp(
        home: const SettingsView(),
        onGenerateRoute: onGenerateRoute,
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme, // Inject the new design system
      );
    },
  );
}
