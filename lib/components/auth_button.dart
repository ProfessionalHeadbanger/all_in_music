import 'package:all_in_music/theme/app_colors.dart';
import 'package:all_in_music/components/gradient_button.dart';

class AuthButton extends GradientButton {
  AuthButton({
    super.key, 
    required super.label,
    required super.onPressed,
    double width = 300.0,
    double height = 40.0,
    double fontSize = 18.0,
  }) : super(
    gradientColors: [
      AppColors.secondaryUnpressedButton,
      AppColors.primaryUnpressedButton,
    ],
    width: width,
    height: height,
    fontSize: fontSize,
  );
}