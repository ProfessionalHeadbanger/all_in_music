import 'package:all_in_music/providers/audio_provider.dart';
import 'package:all_in_music/routing/routing.dart';
import 'package:flutter/material.dart';
import 'package:all_in_music/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.mainTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}