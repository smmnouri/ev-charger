// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localeNotifierHash() => r'c10714060f501418b1e93efe82f1261812c169af';

/// App-lifetime locale notifier.
/// Priority order (per ARCHITECTURE_FINAL.md §25):
///   1. User's stored preference (SharedPreferences)
///   2. Device locale if supported
///   3. English fallback
///
/// Copied from [LocaleNotifier].
@ProviderFor(LocaleNotifier)
final localeNotifierProvider =
    AutoDisposeNotifierProvider<LocaleNotifier, Locale>.internal(
      LocaleNotifier.new,
      name: r'localeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocaleNotifier = AutoDisposeNotifier<Locale>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
