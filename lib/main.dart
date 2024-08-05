import 'package:all_in_music/assets/app_vectors.dart';
import 'package:all_in_music/pages/library_page.dart';
import 'package:all_in_music/pages/search_page.dart';
import 'package:all_in_music/pages/settings_page.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:all_in_music/theme/app_theme.dart';
import 'package:flutter_svg/svg.dart';

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
    return MaterialApp(
      theme: AppTheme.mainTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: currentIndex == 0 ? const MainPage()
                  : currentIndex == 1 ? const SearchPage()
                  : const SettingsPage()
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(AppVectors.libraryIcon, width: 15, height: 15, color: AppColors.primaryIcon,),
              activeIcon: SvgPicture.asset(AppVectors.libraryIcon, width: 15, height: 15, color: AppColors.secondaryIcon,),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(AppVectors.searchIcon, width: 15, height: 15, color: AppColors.primaryIcon),
              activeIcon: SvgPicture.asset(AppVectors.searchIcon, width: 15, height: 15, color: AppColors.secondaryIcon),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(AppVectors.settingsIcon, width: 15, height: 15, color: AppColors.primaryIcon,),
              activeIcon: SvgPicture.asset(AppVectors.settingsIcon, width: 15, height: 15, color: AppColors.secondaryIcon,),
              label: 'Settings',
            ),
          ],
          currentIndex: currentIndex,
          onTap: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
          selectedItemColor: AppColors.secondaryIcon,
          unselectedItemColor: AppColors.primaryIcon,
          selectedLabelStyle: const TextStyle(
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
        ),
      )
    );
  }
}
