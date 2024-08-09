import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SongTile extends StatelessWidget {
  final String title;
  final String artist;
  final int duration;
  final String? coverUrl;
  final Set<String> sources;
  const SongTile({super.key, required this.title, required this.artist, required this.duration, this.coverUrl, required this.sources});

  String formatDuration(int duration) {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: coverUrl != null 
            ? Image.network(coverUrl!, width: 50, height: 50, fit: BoxFit.cover,) 
            : Image.asset("assets/images/default.png", width: 50, height: 50, fit: BoxFit.cover,),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artist,
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
                children: sources.map((source) {
                  switch (source) {
                    case 'VK':
                      return SvgPicture.asset("assets/vectors/VK.svg", color: AppColors.primaryText, width: 20, height: 20,);
                    case 'Spotify': 
                      return SvgPicture.asset("assets/vectors/Spotify.svg", color: AppColors.primaryText, width: 20, height: 20,);
                    case 'YandexMusic':
                      return SvgPicture.asset("assets/vectors/YandexMusic.svg", color: AppColors.primaryText, width: 20, height: 20,);
                    default:
                      return Container();
                  }
                }).toList(),
              ),
              const SizedBox(height: 10),
              Text(
                formatDuration(duration),
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}