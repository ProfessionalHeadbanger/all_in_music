import 'package:all_in_music/assets/app_vectors.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: buildBottomNavBarItems,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        selectedItemColor: AppColors.secondaryIcon,
        unselectedItemColor: AppColors.primaryIcon,
        selectedLabelStyle: const TextStyle(
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> get buildBottomNavBarItems => [
  BottomNavigationBarItem(
    icon: SvgPicture.asset(AppVectors.libraryIcon, width: 15, height: 15, color: AppColors.primaryIcon,),
    activeIcon: SvgPicture.asset(AppVectors.libraryIcon, width: 15, height: 15, color: AppColors.secondaryIcon,),
    label: 'Library',
  ),
  BottomNavigationBarItem(
    icon: SvgPicture.asset(AppVectors.searchIcon, width: 15, height: 15, color: AppColors.primaryIcon,),
    activeIcon: SvgPicture.asset(AppVectors.searchIcon, width: 15, height: 15, color: AppColors.secondaryIcon,),
    label: 'Search',
  ),
  BottomNavigationBarItem(
    icon: SvgPicture.asset(AppVectors.settingsIcon, width: 15, height: 15, color: AppColors.primaryIcon,),
    activeIcon: SvgPicture.asset(AppVectors.settingsIcon, width: 15, height: 15, color: AppColors.secondaryIcon,),
    label: 'Settings',
  )
];
}

