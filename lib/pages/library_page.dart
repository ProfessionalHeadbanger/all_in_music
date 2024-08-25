import 'package:all_in_music/assets/app_vectors.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/components/filter_button.dart';
import 'package:all_in_music/components/mini_player.dart';
import 'package:all_in_music/components/song_tile.dart';
import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/providers/audio_provider.dart';
import 'package:all_in_music/providers/current_audio_provider.dart';
import 'package:all_in_music/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isVkMusicSelected = false;
  bool _isYandexMusicSelected = false;
  String _currentSortOption = 'Default';

  @override
  void initState() {
    super.initState();
    
    context.read<CurrentAudioProvider>().audioPlayer?.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        if (context.read<CurrentAudioProvider>().isRepeatMode) {
          await context.read<CurrentAudioProvider>().audioPlayer?.seek(Duration.zero);
          context.read<CurrentAudioProvider>().audioPlayer?.play();
        } 
        else {
          await context.read<CurrentAudioProvider>().playNextTrack(context);
        }
      }
    });
  }

  void _onSongSelected(Audio audio) {
    context.read<CurrentAudioProvider>().setAudio(audio);
    context.read<CurrentAudioProvider>().playAudio(context);
  }

  void _onShuffleSelected() {
    context.read<CurrentAudioProvider>().shuffleAndPlay();
    context.read<CurrentAudioProvider>().playAudio(context);
  }

  List<Audio> _filterAndSortAudioList(List<Audio> audioList) {
    List<Audio> filteredList;

    if (_isVkMusicSelected && !_isYandexMusicSelected) {
      filteredList = audioList.where((audio) => audio.sources.contains('VK')).toList();
    } 
    else if (_isYandexMusicSelected && !_isVkMusicSelected) {
      filteredList = audioList.where((audio) => audio.sources.contains('YandexMusic')).toList();
    } 
    else {
      filteredList = List<Audio>.from(audioList);
    }

    switch (_currentSortOption) {
      case 'Title':
        filteredList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Artist':
        filteredList.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case 'Default':
      default:
        // Если выбрано "по умолчанию", не нужно сортировать
        break;
    }

    return filteredList;
  }

  void _onVkFilterSelected() {
    setState(() {
      _isVkMusicSelected = !_isVkMusicSelected;
      if (_isVkMusicSelected && _isYandexMusicSelected) {
        _isVkMusicSelected = false;
        _isYandexMusicSelected = false;
      }
    });
  }

  void _onYandexFilterSelected() {
    setState(() {
      _isYandexMusicSelected = !_isYandexMusicSelected;
      if (_isVkMusicSelected && _isYandexMusicSelected) {
        _isVkMusicSelected = false;
        _isYandexMusicSelected = false;
      }
    });
  }

  void _onSortOptionSelected(String option) {
    setState(() {
      _currentSortOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Your Library',
        actions: [
          PopupMenuButton<String>(
            onSelected: _onSortOptionSelected, 
            itemBuilder: (BuildContext context) {
              return {'Default', 'Title', 'Artist'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            icon: SvgPicture.asset(
              AppVectors.sortIcon,
              color: AppColors.primaryIcon,
              width: 18,
              height: 18,
            ),
          ),
        ],
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          final filteredAudioList = _filterAndSortAudioList(audioProvider.audioList);
          context.read<CurrentAudioProvider>().setAudioList(filteredAudioList);
          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            FilterButton(
                              label: 'VK Music',
                              onPressed: _onVkFilterSelected,
                              gradientColors: _isVkMusicSelected 
                                ? [AppColors.primaryPressedButton, AppColors.secondaryPressedButton]
                                : [AppColors.primaryUnpressedButton, AppColors.secondaryUnpressedButton],
                            ),
                            const SizedBox(width: 10,),
                            FilterButton(
                              label: 'Yandex Music',
                              onPressed: _onYandexFilterSelected,
                              gradientColors: _isYandexMusicSelected 
                                ? [AppColors.primaryPressedButton, AppColors.secondaryPressedButton]
                                : [AppColors.primaryUnpressedButton, AppColors.secondaryUnpressedButton],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _onShuffleSelected, 
                          icon: SvgPicture.asset(
                            AppVectors.shuffle,
                            color: AppColors.primaryIcon,
                            width: 18,
                            height: 18,
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredAudioList.length,
                      itemBuilder: (context, index) {
                        final audio = filteredAudioList[index];
                        return SongTile(
                          audio: audio,
                          onTap: () => _onSongSelected(audio),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (context.watch<CurrentAudioProvider>().currentAudio != null) Align(
                alignment: Alignment.bottomCenter,
                child: MiniPlayer(
                  audio: context.watch<CurrentAudioProvider>().currentAudio!,
                  audioPlayer: context.watch<CurrentAudioProvider>().audioPlayer!,
                  onTap: () {
                    context.push('/player');
                  },
                ),
              ),
            ],
          );
        }
      )
    );
  }
}