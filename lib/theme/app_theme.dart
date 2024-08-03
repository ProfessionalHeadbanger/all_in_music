import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final mainTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.primaryBackground,
    brightness: Brightness.dark,
    fontFamily: 'CenturyGothic',
  );
}