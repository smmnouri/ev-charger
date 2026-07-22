import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/locale_provider.dart';
import '../services/server_config_service.dart';
import '../storage/secure_storage.dart';
import 'api_url.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/locale_interceptor.dart';

part 'dio_client.g.dart';

/// Server root for the backend.
/// Override via --dart-define=API_BASE_URL=https://... at build time.
const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.evcharger.ir',
);

const _connectTimeout = Duration(seconds: 15);
const _receiveTimeout = Duration(seconds: 30);

@riverpod
Dio dioClient(Ref ref) {
  final storage = ref.read(secureStorageProvider);

  // Use the runtime server URL if one has been configured; otherwise fall
  // back to the compile-time default baked in via --dart-define.
  final savedUrl = ref.watch(serverUrlProvider);
  final String baseUrl = savedUrl.isNotEmpty ? savedUrl : _apiBaseUrl;

  final dio = Dio(
    BaseOptions(
      baseUrl: buildApiBaseUrl(baseUrl),
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(storage),
    LocaleInterceptor(() => ref.read(localeNotifierProvider)),
    LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => debugPrint('[Dio] $obj'),
    ),
  ]);

  return dio;
}
