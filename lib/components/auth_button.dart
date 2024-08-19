import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatefulWidget {
  final String label;
  final String iconPath;
  final String? userAvatarUrl;
  final VoidCallback onPressed;
  final Color buttonColor;

  const AuthButton({super.key, required this.label, required this.iconPath, this.userAvatarUrl, required this.onPressed, required this.buttonColor});

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  late String? currentImage;

  @override
  void initState() {
    super.initState();
    currentImage = widget.userAvatarUrl ?? widget.iconPath;
  }

  @override
  void didUpdateWidget(covariant AuthButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userAvatarUrl != oldWidget.userAvatarUrl) {
      setState(() {
        currentImage = widget.userAvatarUrl ?? widget.iconPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: widget.onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (currentImage != null) 
              CircleAvatar(
                radius: 16,
                backgroundImage: widget.userAvatarUrl != null ? NetworkImage(currentImage!) : AssetImage(currentImage!) as ImageProvider,
                backgroundColor: Colors.transparent,
              ),
            const SizedBox(width: 15),
            const Spacer(),
            Text(
              widget.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
            ),
            const Spacer(flex: 2,),
          ],
        ),
      ),
    );
  }
}