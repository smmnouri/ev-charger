import 'package:dio/dio.dart';

import '../../storage/secure_storage.dart';

/// Attaches the JWT bearer token to every outgoing request.
/// Source of truth: ARCHITECTURE_FINAL.md §12 (JWT pipeline)
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 — token expired or invalid. Let callers handle via AsyncValue.error.
    handler.next(err);
  }
}
