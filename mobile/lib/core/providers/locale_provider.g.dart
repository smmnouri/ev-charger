// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-lifetime locale notifier.
/// Priority order (per ARCHITECTURE_FINAL.md §25):
///   1. User's stored preference (SharedPreferences)
///   2. Device locale if supported
///   3. English fallback

@ProviderFor(LocaleNotifier)
final localeProvider = LocaleNotifierProvider._();

/// App-lifetime locale notifier.
/// Priority order (per ARCHITECTURE_FINAL.md §25):
///   1. User's stored preference (SharedPreferences)
///   2. Device locale if supported
///   3. English fallback
final class LocaleNotifierProvider
    extends $NotifierProvider<LocaleNotifier, Locale> {
  /// App-lifetime locale notifier.
  /// Priority order (per ARCHITECTURE_FINAL.md §25):
  ///   1. User's stored preference (SharedPreferences)
  ///   2. Device locale if supported
  ///   3. English fallback
  LocaleNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeNotifierHash();

  @$internal
  @override
  LocaleNotifier create() => LocaleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$localeNotifierHash() => r'c10714060f501418b1e93efe82f1261812c169af';

/// App-lifetime locale notifier.
/// Priority order (per ARCHITECTURE_FINAL.md §25):
///   1. User's stored preference (SharedPreferences)
///   2. Device locale if supported
///   3. English fallback

abstract class _$LocaleNotifier extends $Notifier<Locale> {
  Locale build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Locale, Locale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale, Locale>,
              Locale,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
