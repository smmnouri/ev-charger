import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/charging/presentation/screens/charging_session_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/scan/presentation/screens/scan_screen.dart';
import '../../features/charging/presentation/screens/charging_summary_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/notification/presentation/screens/notification_center_screen.dart';
import '../../features/wallet/presentation/screens/topup_screen.dart';
import '../../features/wallet/presentation/screens/transaction_detail_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/kyc_screen.dart';
import '../../features/profile/presentation/screens/kyc_status_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/security_screen.dart';
import '../../features/reservation/presentation/screens/reservation_create_screen.dart';
import '../../features/reservation/presentation/screens/reservation_detail_screen.dart';
import '../../features/reservation/presentation/screens/reservation_list_screen.dart';
import '../../features/support/presentation/screens/faq_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import '../../features/support/presentation/screens/ticket_create_screen.dart';
import '../../features/support/presentation/screens/ticket_detail_screen.dart';
import '../../features/settings/presentation/screens/appearance_screen.dart';
import '../../features/settings/presentation/screens/language_screen.dart';
import '../../features/settings/presentation/screens/notification_preferences_screen.dart';
import '../../features/settings/presentation/screens/location_settings_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/station/presentation/screens/station_details_screen.dart';
import '../../features/station/presentation/screens/station_gallery_screen.dart';
import '../providers/auth_provider.dart';
import 'app_routes.dart';
import 'route_guards.dart';
import 'shell_scaffold.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) => RouteGuards.globalRedirect(authState, state),
    routes: [
      // ── Splash / entry ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingVerify,
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),

      // ── Station (public routes — no auth required) ─────────────────────
      GoRoute(
        path: AppRoutes.stationDetails,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return StationDetailsScreen(stationId: id);
        },
        routes: [
          GoRoute(
            path: 'gallery',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final index = int.tryParse(
                    state.uri.queryParameters['index'] ?? '0',
                  ) ??
                  0;
              return StationGalleryScreen(stationId: id, initialIndex: index);
            },
          ),
        ],
      ),

      // ── Main shell (tab bar) ─────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          // Tab 1 — Map
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),

          // Tab 2 — Reservations
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reservations,
                builder: (context, state) => const ReservationListScreen(),
                routes: [
                  GoRoute(
                    path: 'create/:stationId',
                    builder: (context, state) {
                      final stationId = state.pathParameters['stationId']!;
                      final connectorId =
                          state.uri.queryParameters['connectorId'];
                      return ReservationCreateScreen(
                        stationId: stationId,
                        preselectedConnectorId: connectorId,
                      );
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ReservationDetailScreen(reservationId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 3 — Scan
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scan,
                builder: (context, state) => const ScanScreen(),
              ),
            ],
          ),

          // Tab 4 — History
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),

          // Tab 5 — Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'kyc',
                    builder: (context, state) => const KycScreen(),
                  ),
                  GoRoute(
                    path: 'kyc/status',
                    builder: (context, state) => const KycStatusScreen(),
                  ),
                  GoRoute(
                    path: 'security',
                    builder: (context, state) => const SecurityScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Charging (full-screen, outside shell) ────────────────────────────
      GoRoute(
        path: AppRoutes.chargingSession,
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          final stationId =
              state.uri.queryParameters['stationId'] ?? 's1';
          final connectorId =
              state.uri.queryParameters['connectorId'] ?? 's1c1';
          return ChargingSessionScreen(
            sessionId: sessionId,
            stationId: stationId,
            connectorId: connectorId,
          );
        },
        routes: [
          GoRoute(
            path: 'summary',
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId']!;
              return ChargingSummaryScreen(sessionId: sessionId);
            },
          ),
        ],
      ),

      // ── Wallet ───────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.wallet,
        builder: (context, state) => const WalletScreen(),
        routes: [
          GoRoute(
            path: 'topup',
            builder: (context, state) => const TopupScreen(),
          ),
          GoRoute(
            path: 'transactions/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TransactionDetailScreen(transactionId: id);
            },
          ),
        ],
      ),

      // ── Notifications ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationCenterScreen(),
      ),

      // ── Support ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.support,
        builder: (context, state) => const SupportScreen(),
        routes: [
          GoRoute(
            path: 'faq',
            builder: (context, state) => const FaqScreen(),
          ),
          GoRoute(
            path: 'tickets/new',
            builder: (context, state) => const TicketCreateScreen(),
          ),
          GoRoute(
            path: 'tickets/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TicketDetailScreen(ticketId: id);
            },
          ),
        ],
      ),

      // ── Settings ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'language',
            builder: (context, state) => const LanguageScreen(),
          ),
          GoRoute(
            path: 'appearance',
            builder: (context, state) => const AppearanceScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationPreferencesScreen(),
          ),
          GoRoute(
            path: 'location',
            builder: (context, state) => const LocationSettingsScreen(),
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => _ErrorPage(error: state.error),
  );
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({required this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(error?.toString() ?? 'Page not found'),
      ),
    );
  }
}
