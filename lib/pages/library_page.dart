import 'package:all_in_music/api/yandex_api/yandex_api.dart';
import 'package:all_in_music/assets/app_vectors.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/components/filter_button.dart';
import 'package:all_in_music/components/mini_player.dart';
import 'package:all_in_music/components/song_tile.dart';
import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/models/playback_queue.dart';
import 'package:all_in_music/providers/audio_provider.dart';
import 'package:all_in_music/providers/auth_provider.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlaybackQueue? _playbackQueue;
  Audio? _currentAudio;

  @override
  void initState() {
    super.initState();

    _audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        try {
          setState(() {
            print('Track completed, advancing queue.');
            _playbackQueue?.advanceQueue();
            _currentAudio = _playbackQueue?.currentAudio;
          });
          if (_currentAudio != null) {
            await _playAudio(context.read<AuthProvider>().yandexAccessToken);
          } else {
            print('No audio to play next.');
          }
        } catch (e, stacktrace) {
          print('Error while advancing queue: $e');
          print('Stacktrace: $stacktrace');
        }
      }
    });
  }

  Future<void> _playAudio(String? yandexToken) async {
    if (_currentAudio != null) {
      print('Starting playback for: ${_currentAudio!.title}');
        if (_currentAudio!.sources.contains('VK')) {
          if (_currentAudio!.mp3Url != null && _currentAudio!.mp3Url != "") {
            await _audioPlayer.setUrl(_currentAudio!.mp3Url!);
            _audioPlayer.play();
          }
        } else {
          final mp3Url = await getTrackUrl(_currentAudio!.id, yandexToken!);
          if (mp3Url != null) {
            await _audioPlayer.setUrl(mp3Url);
            _audioPlayer.play();
          } else {
            print('Failed to retrieve MP3 URL for Yandex Music track.');
          }
        }
    }
  }

  void _onSongSelected(Audio audio) {
    setState(() {
      final audioList = context.read<AudioProvider>().audioList;
      _playbackQueue = PlaybackQueue(audioList);
      int startIndex = audioList.indexOf(audio);
      _playbackQueue?.createQueueFrom(startIndex);
      _currentAudio = audio;
    });

    _playAudio(context.read<AuthProvider>().yandexAccessToken);
  }

  void _onShuffleSelected() {
    setState(() {
      final audioList = context.read<AudioProvider>().audioList;
      _playbackQueue = PlaybackQueue(audioList);
      _playbackQueue?.createShuffledQueue();
      _currentAudio = _playbackQueue!.currentAudio;
    });

    _playAudio(context.read<AuthProvider>().yandexAccessToken);
  }

  @override
  Widget build(BuildContext context) {
    final audioList = context.watch<AudioProvider>().audioList;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Your Library',
        actions: [
          IconButton(
            onPressed: (){}, 
            icon: SvgPicture.asset(
              AppVectors.sortIcon,
              color: AppColors.primaryIcon,
              width: 18,
              height: 18,
            ),
          ),
        ],
      ),
      body: Stack(
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
                          onPressed: (){},
                        ),
                        const SizedBox(width: 10,),
                        FilterButton(
                          label: 'Yandex Music',
                          onPressed: (){},
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
                  itemCount: audioList.length,
                  itemBuilder: (context, index) {
                    final audio = audioList[index];
                    return SongTile(
                      title: audio.title, 
                      artist: audio.artist, 
                      duration: audio.duration, 
                      sources: audio.sources, 
                      coverUrl: audio.coverUrl,
                      onTap: () => _onSongSelected(audio),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_currentAudio != null) Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(
              audio: _currentAudio!, 
              audioPlayer: _audioPlayer,
              onTap: () {
                context.push('/player', extra: {'audio': _currentAudio!, 'audioPlayer': _audioPlayer});
              },
            )
          ),
        ],
      ),
    );
  }
}