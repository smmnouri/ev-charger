// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'dc5821ba542b74015cf18f4ef72a4fac837220be';

/// Convenience provider — exposes just the [AuthState] value.
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeProvider<AuthState>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeProviderRef<AuthState>;
String _$authNotifierHash() => r'41a7be6fc0ba8cf08067f149463dac1ca6146725';

/// Holds the current authentication state. Initialises as [AuthState.unknown]
/// while the app reads the stored JWT from secure storage on startup.
/// keepAlive: true prevents auto-disposal between main() resolveFromStorage
/// and the first frame — without this the state resets to unknown before the
/// GoRouter reads it, causing the app to stay on the splash screen indefinitely.
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = Notifier<AuthState>;
String _$kycStatusNotifierHash() => r'74792f840c97a53ae9981324c68760256de28c37';

/// KYC status for the authenticated user. Populated after profile fetch.
///
/// Copied from [KycStatusNotifier].
@ProviderFor(KycStatusNotifier)
final kycStatusNotifierProvider =
    AutoDisposeNotifierProvider<KycStatusNotifier, KycStatus>.internal(
      KycStatusNotifier.new,
      name: r'kycStatusNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$kycStatusNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$KycStatusNotifier = AutoDisposeNotifier<KycStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
