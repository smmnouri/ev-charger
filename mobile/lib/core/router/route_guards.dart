import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import 'app_routes.dart';

/// Centralised redirect logic for Go Router.
/// Source of truth: docs/ui/SCREEN_INVENTORY_FINAL.md §5
abstract final class RouteGuards {
  /// Called on every navigation event. Returns a redirect path or null.
  static String? globalRedirect(AuthState authState, GoRouterState state) {
    final isOnAuthRoute = state.matchedLocation == AppRoutes.onboarding ||
        state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.onboardingVerify;

    switch (authState) {
      case AuthState.unknown:
        // Still loading — stay on splash
        if (state.matchedLocation == AppRoutes.splash) return null;
        return AppRoutes.splash;

      case AuthState.unauthenticated:
        // Allow only auth routes and public station routes
        if (isOnAuthRoute) return null;
        if (state.matchedLocation.startsWith('/stations/')) return null;
        // Redirect to onboarding, saving intended destination
        final redirectTo = state.matchedLocation;
        if (redirectTo == AppRoutes.splash) return AppRoutes.onboarding;
        return '${AppRoutes.onboarding}?redirect=${Uri.encodeComponent(redirectTo)}';

      case AuthState.authenticated:
        // Redirect away from auth and splash
        if (isOnAuthRoute || state.matchedLocation == AppRoutes.splash) {
          return AppRoutes.map;
        }
        return null;
    }
  }

  /// KYC guard — call at the point of a KYC-gated action.
  /// Returns true if the user may proceed, false if KYC is required.
  static bool kycRequired(KycStatus status) {
    return status != KycStatus.approved;
  }
}
