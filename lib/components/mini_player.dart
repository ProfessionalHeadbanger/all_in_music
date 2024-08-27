import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class MiniPlayer extends StatefulWidget {
  final Audio audio;
  final AudioHandler audioHandler;
  final VoidCallback? onTap;

  const MiniPlayer({super.key, required this.audio, required this.audioHandler, this.onTap});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
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
                  child: widget.audio.coverUrl != null 
                  ? Image.network(widget.audio.coverUrl!, width: 40, height: 40, fit: BoxFit.cover,) 
                  : Image.asset("assets/images/default.png", width: 40, height: 40, fit: BoxFit.cover,),
                ),
                const SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.audio.title,
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.audio.artist,
                        style: const TextStyle(
                          color: AppColors.miniPlayerArtistText,
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
                  icon: StreamBuilder<PlaybackState>(
                    stream: widget.audioHandler.playbackState, 
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
                    if (widget.audioHandler.playbackState.value.playing) {
                      widget.audioHandler.pause();
                    }
                    else {
                      widget.audioHandler.play();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 6,),
            StreamBuilder<Duration>(
              stream: widget.audioHandler.playbackState.map((state) => state.updatePosition),
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: widget.audioHandler.mediaItem.map((item) => item?.duration),
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    return LinearProgressIndicator(
                      value: duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0,
                      backgroundColor: AppColors.secondaryAudioProgress,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAudioProgress),
                      borderRadius: BorderRadius.circular(2),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}