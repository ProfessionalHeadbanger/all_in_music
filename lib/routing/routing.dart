import 'package:all_in_music/pages/library_page.dart';
import 'package:all_in_music/pages/root_page.dart';
import 'package:all_in_music/pages/search_page.dart';
import 'package:all_in_music/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/main',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => RootPage(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/main',
              builder: (context, state) => const MainPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ]
    )
  ]
);