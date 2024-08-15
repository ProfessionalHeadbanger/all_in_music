import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayer extends StatelessWidget {
  final Audio audio;
  final AudioPlayer audioPlayer;

  const MiniPlayer({super.key, required this.audio, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      padding: const EdgeInsets.only(left: 12, right: 12, top: 3, bottom: 7),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: audio.coverUrl != null 
                ? Image.network(audio.coverUrl!, width: 40, height: 40, fit: BoxFit.cover,) 
                : Image.asset("assets/images/default.png", width: 40, height: 40, fit: BoxFit.cover,),
              ),
              const SizedBox(width: 12,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      audio.title,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      audio.artist,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: StreamBuilder<PlayerState>(
                  stream: audioPlayer.playerStateStream, 
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    return Icon(
                      playerState?.playing == true ? Icons.pause : Icons.play_arrow,
                      color: AppColors.primaryText,
                      size: 30,
                    );
                  }
                ),
                onPressed: () {
                  if (audioPlayer.playing) {
                    audioPlayer.pause();
                  }
                  else {
                    audioPlayer.play();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 6,),
          StreamBuilder<Duration>(
            stream: audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              return LinearProgressIndicator(
                value: position.inMilliseconds / (audioPlayer.duration?.inMilliseconds ?? 1),
                backgroundColor: AppColors.secondaryAudioProgress,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAudioProgress),
                borderRadius: BorderRadius.circular(2),
              );
            },
          ),
        ],
      ),
    );
  }
}