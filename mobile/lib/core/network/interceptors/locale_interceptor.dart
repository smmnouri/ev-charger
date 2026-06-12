import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Adds the Accept-Language header to every request based on the active locale.
/// Source of truth: ARCHITECTURE_FINAL.md §25 — "Accept-Language header on all requests"
class LocaleInterceptor extends Interceptor {
  LocaleInterceptor(this._localeGetter);

  /// Getter injected at construction so the interceptor always reads the
  /// current locale rather than capturing a stale value.
  final Locale Function() _localeGetter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _localeGetter().toLanguageTag();
    handler.next(options);
  }
}
