import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final double borderRadius;
  final double width;
  final double height;
  final double fontSize;

  const GradientButton({
    super.key, 
    required this.label, 
    required this.onPressed, 
    required this.gradientColors, 
    this.borderRadius = 100.0,
    this.width = 100.0,
    this.height = 50.0,
    this.fontSize = 16.0,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          )
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.primaryText,
          ),
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }
}