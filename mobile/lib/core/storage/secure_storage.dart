import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';

/// Thin wrapper around flutter_secure_storage for JWT persistence.
/// Source of truth: ARCHITECTURE_FINAL.md §12 (JWT storage — flutter_secure_storage)
class SecureStorage {
  const SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
    ]);
  }

  Future<bool> hasAccessToken() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }
}

@riverpod
SecureStorage secureStorage(Ref ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  return SecureStorage(storage);
}
