import 'package:go_router/go_router.dart';

import 'features/placeholder/coming_soon_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/today/today_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/bugun',
  routes: [
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
              builder: (_, _) =>
                  const ComingSoonScreen(title: 'Kontrol listem'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/gecmis',
              builder: (_, _) => const ComingSoonScreen(title: 'Geçmiş'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ayarlar',
              builder: (_, _) => const ComingSoonScreen(title: 'Ayarlar'),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/kontrol',
      builder: (_, _) =>
          const ComingSoonScreen(title: 'Hızlı kontrol', showBack: true),
    ),
  ],
);
