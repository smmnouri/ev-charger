import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/locale_provider.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/locale_interceptor.dart';

part 'dio_client.g.dart';

/// Base URL for the .NET 9 backend.
/// Override via --dart-define=API_BASE_URL=https://... at build time.
const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.evcharger.ir/v1',
);

const _connectTimeout = Duration(seconds: 15);
const _receiveTimeout = Duration(seconds: 30);

@riverpod
Dio dioClient(Ref ref) {
  final storage = ref.read(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
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
