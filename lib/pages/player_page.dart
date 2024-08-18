import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

class PlayerPage extends StatelessWidget {
  final Audio audio;
  final AudioPlayer audioPlayer;
  const PlayerPage({super.key, required this.audio, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(), 
          icon: const Icon(Icons.chevron_left),
        ),
        actions: [
          IconButton(
            onPressed: (){}, 
            icon: const Icon(Icons.more_horiz),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Обложка альбома
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: AspectRatio(
              aspectRatio: 1/1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: audio.coverUrl != null 
                  ? Image.network(audio.coverUrl!, width: 400, height: 400, fit: BoxFit.cover,) 
                  : Image.asset("assets/images/default.png", width: 400, height: 400, fit: BoxFit.cover,),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Название трека и исполнитель
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audio.title, // Используем название трека из объекта Audio
                  style: const TextStyle(fontSize: 22, color: AppColors.primaryText, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  audio.artist, // Используем имя исполнителя из объекта Audio
                  style: const TextStyle(fontSize: 14, color: AppColors.playerArtistText, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Полоса прогресса
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                // Прогресс-бар
                StreamBuilder<Duration?>(
                  stream: audioPlayer.durationStream,
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration>(
                      stream: audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        var position = snapshot.data ?? Duration.zero;
                        if (position > duration) {
                          position = duration;
                        }
                        return SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          ),
                          child: Slider(
                            value: position.inMilliseconds.toDouble(),
                            min: 0.0,
                            max: duration.inMilliseconds.toDouble(),
                            onChanged: (value) {
                              audioPlayer.seek(Duration(milliseconds: value.round()));
                            },
                            activeColor: AppColors.primaryAudioProgress,
                            inactiveColor: AppColors.secondaryAudioProgress,
                          )
                        );
                      },
                    );
                  },
                ),

                // Время и длительность
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<Duration>(
                        stream: audioPlayer.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final minutes = position.inMinutes.toString().padLeft(2, '0');
                          final seconds = (position.inSeconds % 60).toString().padLeft(2, '0');
                          return Text(
                            '$minutes:$seconds',
                            style: const TextStyle(color: AppColors.primaryText, fontSize: 12),
                          );
                        },
                      ),
                      StreamBuilder<Duration?>(
                        stream: audioPlayer.durationStream,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? Duration.zero;
                          final minutes = duration.inMinutes.toString().padLeft(2, '0');
                          final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
                          return Text(
                            '$minutes:$seconds',
                            style: const TextStyle(color: AppColors.primaryText, fontSize: 12),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30,),
          // Элементы управления воспроизведением
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.shuffle, color: Colors.white70),
                onPressed: () {
                  // Обработка нажатия кнопки "Shuffle"
                },
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    iconSize: 30,
                    onPressed: () {
                      // Обработка нажатия кнопки "Previous"
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                    iconSize: 64,
                    onPressed: () {
                      // Обработка нажатия кнопки "Play/Pause"
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    iconSize: 30,
                    onPressed: () {
                      // Обработка нажатия кнопки "Next"
                    },
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.repeat, color: Colors.white70),
                onPressed: () {
                  // Обработка нажатия кнопки "Repeat"
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}