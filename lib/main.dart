import 'package:all_in_music/routing/routing.dart';
import 'package:flutter/material.dart';
import 'package:all_in_music/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
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