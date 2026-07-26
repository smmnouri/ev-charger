import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

enum AuthState { unknown, unauthenticated, authenticated }

enum KycStatus { notStarted, pending, approved, rejected }

/// Holds the current authentication state. Initialises as [AuthState.unknown]
/// while the app reads the stored JWT from secure storage on startup.
/// keepAlive: true prevents auto-disposal between main() resolveFromStorage
/// and the first frame — without this the state resets to unknown before the
/// GoRouter reads it, causing the app to stay on the splash screen indefinitely.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => AuthState.unknown;

  void setAuthenticated() => state = AuthState.authenticated;
  void setUnauthenticated() => state = AuthState.unauthenticated;

  /// Called on app startup after reading secure storage.
  void resolveFromStorage({required bool hasToken}) {
    state = hasToken ? AuthState.authenticated : AuthState.unauthenticated;
  }
}

/// Convenience provider — exposes just the [AuthState] value.
@riverpod
AuthState authState(Ref ref) => ref.watch(authProvider);

/// KYC status for the authenticated user. Populated after profile fetch.
@riverpod
class KycStatusNotifier extends _$KycStatusNotifier {
  @override
  KycStatus build() => KycStatus.notStarted;

  void update(KycStatus status) => state = status;
}
