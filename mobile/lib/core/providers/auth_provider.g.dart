// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the current authentication state. Initialises as [AuthState.unknown]
/// while the app reads the stored JWT from secure storage on startup.
/// keepAlive: true prevents auto-disposal between main() resolveFromStorage
/// and the first frame — without this the state resets to unknown before the
/// GoRouter reads it, causing the app to stay on the splash screen indefinitely.

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

/// Holds the current authentication state. Initialises as [AuthState.unknown]
/// while the app reads the stored JWT from secure storage on startup.
/// keepAlive: true prevents auto-disposal between main() resolveFromStorage
/// and the first frame — without this the state resets to unknown before the
/// GoRouter reads it, causing the app to stay on the splash screen indefinitely.
final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AuthState> {
  /// Holds the current authentication state. Initialises as [AuthState.unknown]
  /// while the app reads the stored JWT from secure storage on startup.
  /// keepAlive: true prevents auto-disposal between main() resolveFromStorage
  /// and the first frame — without this the state resets to unknown before the
  /// GoRouter reads it, causing the app to stay on the splash screen indefinitely.
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authNotifierHash() => r'41a7be6fc0ba8cf08067f149463dac1ca6146725';

/// Holds the current authentication state. Initialises as [AuthState.unknown]
/// while the app reads the stored JWT from secure storage on startup.
/// keepAlive: true prevents auto-disposal between main() resolveFromStorage
/// and the first frame — without this the state resets to unknown before the
/// GoRouter reads it, causing the app to stay on the splash screen indefinitely.

abstract class _$AuthNotifier extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Convenience provider — exposes just the [AuthState] value.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Convenience provider — exposes just the [AuthState] value.

final class AuthStateProvider
    extends $FunctionalProvider<AuthState, AuthState, AuthState>
    with $Provider<AuthState> {
  /// Convenience provider — exposes just the [AuthState] value.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $ProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthState create(Ref ref) {
    return authState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authStateHash() => r'dc5821ba542b74015cf18f4ef72a4fac837220be';

/// KYC status for the authenticated user. Populated after profile fetch.

@ProviderFor(KycStatusNotifier)
final kycStatusProvider = KycStatusNotifierProvider._();

/// KYC status for the authenticated user. Populated after profile fetch.
final class KycStatusNotifierProvider
    extends $NotifierProvider<KycStatusNotifier, KycStatus> {
  /// KYC status for the authenticated user. Populated after profile fetch.
  KycStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycStatusNotifierHash();

  @$internal
  @override
  KycStatusNotifier create() => KycStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KycStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KycStatus>(value),
    );
  }
}

String _$kycStatusNotifierHash() => r'74792f840c97a53ae9981324c68760256de28c37';

/// KYC status for the authenticated user. Populated after profile fetch.

abstract class _$KycStatusNotifier extends $Notifier<KycStatus> {
  KycStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<KycStatus, KycStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KycStatus, KycStatus>,
              KycStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
