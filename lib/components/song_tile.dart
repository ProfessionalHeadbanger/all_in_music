import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/providers/current_audio_provider.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SongTile extends StatelessWidget {
  final Audio audio;
  final VoidCallback? onTap;
  const SongTile({super.key, this.onTap, required this.audio});

  String formatDuration(int duration) {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentAudio = context.watch<CurrentAudioProvider>().currentAudio;
    final isCurrentPlaying = currentAudio == audio;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(10),
          border: isCurrentPlaying
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: audio.coverUrl != null 
              ? Image.network(audio.coverUrl!, width: 50, height: 50, fit: BoxFit.cover,) 
              : Image.asset("assets/images/default.png", width: 50, height: 50, fit: BoxFit.cover,),
            ),
            const SizedBox(width: 10,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audio.title,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    audio.artist,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 13.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: audio.sources.map((source) {
                    Widget icon;
                    switch (source) {
                      case 'VK':
                        icon = SvgPicture.asset("assets/vectors/VK.svg", color: AppColors.primaryText, width: 20, height: 20);
                        break;
                      case 'YandexMusic':
                        icon = SvgPicture.asset("assets/vectors/YandexMusic.svg", color: AppColors.primaryText, width: 20, height: 20);
                        break;
                      default:
                        icon = Container();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: icon,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Text(
                  formatDuration(audio.duration),
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}