import 'package:all_in_music/providers/audio_provider.dart';
import 'package:all_in_music/providers/auth_provider.dart';
import 'package:all_in_music/providers/current_audio_provider.dart';
import 'package:all_in_music/providers/network_provider.dart';
import 'package:all_in_music/routing/routing.dart';
import 'package:flutter/material.dart';
import 'package:all_in_music/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.loadTokens();

  final currentAudioProvider = CurrentAudioProvider();
  await currentAudioProvider.initAudioService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => currentAudioProvider),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0;

  void _syncTracks() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.syncTracks(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTracks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.mainTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}