import 'package:all_in_music/components/gradient_button.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FilterButton extends GradientButton {
  FilterButton({
    super.key, 
    required super.label,
    required super.onPressed,
    List<Color>? gradientColors,
    double width = 100.0,
    double height = 35.0,
    double fontSize = 12.0,
  }) : super(
    gradientColors: gradientColors ?? [
      AppColors.secondaryUnpressedButton,
      AppColors.primaryUnpressedButton,
    ],
    width: width,
    height: height,
    fontSize: fontSize,
  );
}