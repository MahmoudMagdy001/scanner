// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:qrscanner/core/appStorage/app_storage.dart';

class DioHelper {
  static const _defaultBaseUrl = 'https://bestscan.store/api/v1/';

  // ponytail: logging interceptor is disabled in release builds (kDebugMode check)
  // to avoid costly JSON encoding and developer.log overhead in production.
  static final Dio dioSingleton = _createDioSingleton();

  static Dio _createDioSingleton() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _defaultBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        headers: {'Accept': 'application/json', 'Accept-Language': 'en'},
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final body = options.data;
            final bodyStr = body is FormData ? 'FormData' : (body != null ? jsonEncode(body) : 'Empty');
            developer.log(
              '--> ${options.method} ${options.uri}\nHeaders: ${options.headers}\nBody: $bodyStr',
              name: 'API_REQUEST',
            );
            return handler.next(options);
          },
          onResponse: (response, handler) {
            String prettyJson;
            try {
              prettyJson = const JsonEncoder.withIndent('  ').convert(response.data);
            } on Object catch (_) {
              prettyJson = response.data.toString();
            }
            developer.log(
              '<-- ${response.statusCode} ${response.requestOptions.uri}\nResponse Body:\n$prettyJson',
              name: 'API_RESPONSE',
            );
            return handler.next(response);
          },
          onError: (err, handler) {
            String prettyJson;
            try {
              prettyJson = const JsonEncoder.withIndent('  ').convert(err.response?.data);
            } on Object catch (_) {
              prettyJson = err.response?.data.toString() ?? 'No details';
            }
            developer.log('<-- Error: ${err.message}\nResponse Body:\n$prettyJson', name: 'API_ERROR');
            return handler.next(err);
          },
        ),
      );
    }

    return dio;
  }

  // Update base URL dynamically
  static void updateBaseUrl(String baseUrl) {
    var formattedUrl = baseUrl;
    if (!formattedUrl.endsWith('/')) formattedUrl += '/';
    if (!formattedUrl.contains('api/v1')) formattedUrl += 'api/v1/';
    dioSingleton.options.baseUrl = formattedUrl;
  }

  // Initialize with saved base URL or default
  static void initBaseUrl() {
    final savedBaseUrl = AppStorage.getBaseUrl;
    if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
      updateBaseUrl(savedBaseUrl);
    }
  }

  // POST request
  static Future<Response<dynamic>> post(
    String path, {
    required bool isAuth,
    FormData? formData,
    Map<String, dynamic>? body,
    void Function(int, int)? onSendProgress,
  }) {
    final headers = isAuth && AppStorage.getToken != null
        ? {'Authorization': 'Bearer ${AppStorage.getToken}'}
        : <String, dynamic>{};

    // Use JSON content-type when sending body, FormData has its own content-type
    final contentType = formData == null && body != null ? 'application/json' : null;

    final options = contentType != null
        ? Options(headers: {...headers, 'Content-Type': contentType})
        : Options(headers: headers.isNotEmpty ? headers : null);

    return dioSingleton.post(path, data: formData ?? body, options: options, onSendProgress: onSendProgress);
  }

  // ponytail: removed unused delete wrapper

  // GET request
  static Future<Response<dynamic>> get(String path, {bool isAuth = true}) {
    final headers = isAuth && AppStorage.getToken != null ? {'Authorization': 'Bearer ${AppStorage.getToken}'} : null;

    return dioSingleton.get(path, options: Options(headers: headers));
  }
}
