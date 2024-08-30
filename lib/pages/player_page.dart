import 'package:all_in_music/assets/app_vectors.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/providers/current_audio_provider.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:overflow_text_animated/overflow_text_animated.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  void _showShareMenu(BuildContext context, Map<String, String> trackLinks) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.shareMenu,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: trackLinks.entries.map((entry) {
                    return ListTile(
                      leading: _getServiceIcon(entry.key),
                      title: Text('Share from ${_getServiceName(entry.key)}', style: const TextStyle(color: AppColors.primaryText),),
                      onTap: () {
                        _shareTrack(entry.value);
                      },
                    );
                }).toList(),
              ),
            )
          ),
        );
      }
    );
  }

  Widget _getServiceIcon(String key) {
    switch (key) {
      case 'VK':
        return SvgPicture.asset(AppVectors.vkLogo);
      case 'YandexMusic':
        return SvgPicture.asset(AppVectors.yandexLogo);
      default:
        return const Icon(Icons.share);
    }
  }

  String _getServiceName(String key) {
    switch (key) {
      case 'VK':
        return 'VK Music';
      case 'YandexMusic':
        return 'Yandex Music';
      default:
        return key;
    }
  }

  void _shareTrack(String url) async {
    final result = await Share.share(url);
    if (result.status == ShareResultStatus.success)
    {
      print('Shared: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAudio = context.watch<CurrentAudioProvider>().currentAudio;
    final audioHandler = context.watch<CurrentAudioProvider>().audioHandler;

    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(), 
          icon: SvgPicture.asset(
                  AppVectors.chevronLeft,
                  color: AppColors.primaryIcon,
                  width: 21,
                  height: 21,
                ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showShareMenu(context, currentAudio!.trackLinks), 
            icon: SvgPicture.asset(
                  AppVectors.moreHorizontal,
                  color: AppColors.primaryIcon,
                  width: 21,
                  height: 21,
                ),
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
                child: currentAudio!.coverUrl != null 
                  ? Image.network(currentAudio.coverUrl!, width: 400, height: 400, fit: BoxFit.cover,) 
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
                OverflowTextAnimated(
                  key: ValueKey(currentAudio.title),
                  text: currentAudio.title, 
                  style: const TextStyle(fontSize: 22, color: AppColors.primaryText, fontWeight: FontWeight.bold),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  animation: OverFlowTextAnimations.scrollOpposite,
                  animateDuration: const Duration(milliseconds: 3000),
                  delay: const Duration(milliseconds: 1000),
                ),
                const SizedBox(height: 8),
                OverflowTextAnimated(
                  key: ValueKey(currentAudio.artist),
                  text: currentAudio.artist,
                  style: const TextStyle(fontSize: 14, color: AppColors.playerArtistText, fontWeight: FontWeight.bold),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  animation: OverFlowTextAnimations.scrollOpposite,
                  animateDuration: const Duration(milliseconds: 3000),
                  delay: const Duration(milliseconds: 1000),
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
                  stream: audioHandler.mediaItem.map((item) => item?.duration),
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration>(
                      stream: audioHandler.playbackState.map((state) => state.position),
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
                              audioHandler.seek(Duration(milliseconds: value.round()));
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
                        stream: audioHandler.playbackState.map((state) => state.position),
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
                        stream: audioHandler.mediaItem.map((item) => item?.duration),
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
                icon: SvgPicture.asset(
                  AppVectors.shuffle,
                  color: context.watch<CurrentAudioProvider>().isShuffleMode ? AppColors.secondaryIcon : AppColors.primaryIcon,
                  width: 21,
                  height: 21,
                ),
                onPressed: () {
                  context.read<CurrentAudioProvider>().toggleShuffleMode();
                },
              ),
              Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      AppVectors.skipBack,
                      color: AppColors.primaryIcon,
                      width: 21,
                      height: 21,
                    ),
                    onPressed: () async {
                      await context.read<CurrentAudioProvider>().playPreviousTrack(context);
                    },
                  ),
                  IconButton(
                    icon: StreamBuilder<PlaybackState>(
                      stream: audioHandler.playbackState, 
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final isPlaying = playerState?.playing;
                        if (isPlaying == true) {
                          return const Icon(Icons.pause_circle_filled, color: Colors.white,);
                        }
                        else {
                          return const Icon(Icons.play_circle_fill, color: Colors.white,);
                        }
                      },
                    ),
                    iconSize: 64,
                    onPressed: () {
                      if (audioHandler.playbackState.value.playing) {
                        audioHandler.pause();
                      }
                      else {
                        audioHandler.play();
                      }
                    },
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      AppVectors.skipForward,
                      color: AppColors.primaryIcon,
                      width: 21,
                      height: 21,
                    ),
                    onPressed: () async {
                      await context.read<CurrentAudioProvider>().playNextTrack(context);
                    },
                  ),
                ],
              ),
              IconButton(
                icon: SvgPicture.asset(
                  AppVectors.repeat,
                  color: context.watch<CurrentAudioProvider>().isRepeatMode ? AppColors.secondaryIcon : AppColors.primaryIcon,
                  width: 21,
                  height: 21,
                ),
                onPressed: () {
                  context.read<CurrentAudioProvider>().toggleRepeatMode();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}