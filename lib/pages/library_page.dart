import 'package:all_in_music/api/yandex_api/yandex_api.dart';
import 'package:all_in_music/assets/app_vectors.dart';
import 'package:all_in_music/components/custom_app_bar.dart';
import 'package:all_in_music/components/filter_button.dart';
import 'package:all_in_music/components/mini_player.dart';
import 'package:all_in_music/components/song_tile.dart';
import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/providers/audio_provider.dart';
import 'package:all_in_music/providers/auth_provider.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Audio> _audioList = [];
  List<Audio> _shuffledAudioList = [];
  Audio? _currentAudio;
  bool _isShuffleMode = false;

  @override
  void initState() {
    super.initState();

    _audioList = context.read<AudioProvider>().audioList;
    
    _audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await _onTrackComplete();
      }
    });
  }

  Future<void> _onTrackComplete() async {
    await _playNextTrack();
  }

  Future<void> _playAudio(Audio audio) async {
    final audioProvider = context.read<CurrentAudioProvider>();
    audioProvider.setAudio(audio, _audioPlayer);

    if (audio.sources.contains('VK')) {
      if (audio.mp3Url != null && audio.mp3Url != "") {
        await _audioPlayer.setUrl(audio.mp3Url!);
        _audioPlayer.play();
      }
    } else {
      final mp3Url = await getTrackUrl(audio.id, context.read<AuthProvider>().yandexAccessToken!);
      if (mp3Url != null) {
        await _audioPlayer.setUrl(mp3Url);
        _audioPlayer.play();
      } else {
        print('Failed to retrieve MP3 URL for Yandex Music track.');
      }
    }
  }

  Future<void> _playNextTrack() async {
  if (_isShuffleMode) {
    final currentIndex = _shuffledAudioList.indexOf(_currentAudio!);
    final nextIndex = (currentIndex + 1) % _shuffledAudioList.length;
    _currentAudio = _shuffledAudioList[nextIndex];
  } else {
    final currentIndex = _audioList.indexOf(_currentAudio!);
    final nextIndex = (currentIndex + 1) % _audioList.length;
    _currentAudio = _audioList[nextIndex];
  }

  await _playAudio(_currentAudio!);
  context.read<CurrentAudioProvider>().setAudio(_currentAudio!, _audioPlayer);
}

  void _onSongSelected(Audio audio) {
    setState(() {
      _isShuffleMode = false;
      _currentAudio = audio;
      _playAudio(audio);
    });
  }

  void _onShuffleSelected() {
  setState(() {
    _isShuffleMode = true;
    _shuffledAudioList = List<Audio>.from(_audioList);
    _shuffledAudioList.shuffle();
    _playAudio(_shuffledAudioList.first);
  });
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
            child: Consumer<CurrentAudioProvider>(
              builder: (context, currentAudioProvider, _) {
                return MiniPlayer(
                  audio: context.read<CurrentAudioProvider>().currentAudio!, 
                  audioPlayer: context.read<CurrentAudioProvider>().audioPlayer!,
                  onTap: () {
                    context.push('/player');
                  },
                );
              }
            )
          ),
        ],
      ),
    );
  }
}