import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/day_mode.dart';
import 'data/app_state.dart';
import 'features/check/quick_check_screen.dart';
import 'features/checklist/checklist_screen.dart';
import 'features/history/history_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/setup/setup_guide_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/today/today_screen.dart';
import 'features/trigger/trigger_screen.dart';

DayMode? _modeParam(GoRouterState state) =>
    switch (state.uri.queryParameters['mod']) {
      'aksam' => DayMode.evening,
      'sabah' => DayMode.morning,
      _ => null,
    };

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/bugun',
    // İlk açılışta onboarding gösterilir; bitince bir daha gösterilmez.
    redirect: (context, state) {
      final seen = ref.read(onboardingSeenProvider);
      final atOnboarding = state.matchedLocation == '/hosgeldin';
      if (!seen && !atOnboarding) return '/hosgeldin';
      if (seen && atOnboarding) return '/bugun';
      return null;
    },
    routes: [
      GoRoute(path: '/hosgeldin', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/bugun', builder: (_, _) => const TodayScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/liste',
                builder: (_, _) => const ChecklistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/gecmis',
                builder: (_, _) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ayarlar',
                builder: (_, _) => const TriggerScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/kontrol',
        builder: (_, state) => QuickCheckScreen(
          mode: _modeParam(state),
          fromBackup: state.uri.queryParameters['kaynak'] == 'yedek',
        ),
      ),
      GoRoute(
        path: '/kurulum',
        builder: (_, state) => SetupGuideScreen(mode: _modeParam(state)),
      ),
    ],
  );
});
