import 'package:all_in_music/pages/library_page.dart';
import 'package:all_in_music/pages/root_page.dart';
import 'package:all_in_music/pages/search_page.dart';
import 'package:all_in_music/pages/settings_page.dart';
import 'package:all_in_music/pages/spotify_login_page.dart';
import 'package:all_in_music/pages/vk_login_page.dart';
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
              routes: [
                GoRoute(
                  path: 'spotify-auth',
                  builder: (context, state) => const SpotifyLoginPage(clientId: "be788300710c45cd89683cdb8bd5268b", redirectUri: "http://localhost:3000", clientSecret: "9c1ec56a023842748b26a0e3b5ef0842"),
                ),
                GoRoute(
                  path: 'vk-auth',
                  builder: (context, state) => const VkLoginPage(),
                ),
              ]
            ),
          ],
        ),
      ]
    )
  ]
);
