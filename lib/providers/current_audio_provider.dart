import 'package:all_in_music/api/yandex_api/yandex_api.dart';
import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/providers/auth_provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class CurrentAudioProvider with ChangeNotifier {
  Audio? _currentAudio;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AudioHandler _audioHandler;
  List<Audio> _audioList = [];
  List<Audio> _shuffledAudioList = [];
  List<Audio> _playbackHistory = [];
  int _currentHistoryIndex = -1;
  bool _isShuffleMode = false;
  bool _isRepeatMode = false;

  Audio? get currentAudio => _currentAudio;
  AudioHandler get audioHandler => _audioHandler;
  bool get isShuffleMode => _isShuffleMode;
  bool get isRepeatMode => _isRepeatMode;

  Future<void> initAudioService() async {
    _audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(_audioPlayer),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.all_in_music.channel.audio',
        androidNotificationChannelName: 'Music Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }

  void setAudio(Audio audio) {
    _currentAudio = audio;
    _isShuffleMode = false;
    notifyListeners();
  }

  void setAudioList(List<Audio> audioList) {
    _audioList = audioList;
    _shuffledAudioList = List<Audio>.from(_audioList);
    _shuffledAudioList.shuffle();
    _checkForEmptyAudioList();
  }

  void _checkForEmptyAudioList() {
    if (_audioList.isEmpty) {
      _currentAudio = null;
      _audioHandler.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void toggleShuffleMode() {
    _isShuffleMode = !_isShuffleMode;
    notifyListeners();
  }

  void shuffleAndPlay(BuildContext context) {
    if (_audioList.isNotEmpty) {
      _isShuffleMode = true;
      _shuffledAudioList = List<Audio>.from(_audioList);
      _shuffledAudioList.shuffle();
      _currentAudio = _shuffledAudioList.first;
      notifyListeners();
      playAudio(context);
    }
  }

  void toggleRepeatMode() {
    _isRepeatMode = !_isRepeatMode;
    notifyListeners();
    (audioHandler as AudioPlayerHandler).setLoopMode(_isRepeatMode ? LoopMode.one : LoopMode.off);
  }

  Future<void> playPreviousTrack(BuildContext context) async {
    if (_currentHistoryIndex > 0) {
      _currentHistoryIndex--;
      _currentAudio = _playbackHistory[_currentHistoryIndex];
    } else {
      // Если истории нет, используем стандартное поведение
      if (_isShuffleMode) {
        final currentIndex = _shuffledAudioList.indexOf(_currentAudio!);
        final previousIndex = (currentIndex - 1 + _shuffledAudioList.length) % _shuffledAudioList.length;
        _currentAudio = _shuffledAudioList[previousIndex];
      } else {
        final currentIndex = _audioList.indexOf(_currentAudio!);
        final previousIndex = (currentIndex - 1 + _audioList.length) % _audioList.length;
        _currentAudio = _audioList[previousIndex];
      }
      _playbackHistory.insert(0, _currentAudio!);
      _currentHistoryIndex = 0;
    }

    notifyListeners();
    await playAudio(context);
  }

  Future<void> playNextTrack(BuildContext context) async {
    if (_currentHistoryIndex == -1 || (_currentHistoryIndex >= 0 && _currentAudio != _playbackHistory[_currentHistoryIndex])) {
      _playbackHistory.add(_currentAudio!);
      _currentHistoryIndex++;
    }

    if (_isShuffleMode) {
      final currentIndex = _shuffledAudioList.indexOf(_currentAudio!);
      final nextIndex = (currentIndex + 1) % _shuffledAudioList.length;
      _currentAudio = _shuffledAudioList[nextIndex];
    } else {
      final currentIndex = _audioList.indexOf(_currentAudio!);
      final nextIndex = (currentIndex + 1) % _audioList.length;
      _currentAudio = _audioList[nextIndex];
    }

    if (_currentHistoryIndex < _playbackHistory.length - 1) {
      _playbackHistory = _playbackHistory.sublist(0, _currentHistoryIndex + 1);
    }
    _playbackHistory.add(_currentAudio!);
    _currentHistoryIndex++;

    notifyListeners();
    await playAudio(context);
  }

  Future<void> playAudio(BuildContext context) async {
    if (_currentAudio == null) return;
    String? url;
    if (_currentAudio!.sources.contains('VK')) {
      url = _currentAudio!.mp3Url;
    }
    else {
      url = await getTrackUrl(_currentAudio!.id, context.read<AuthProvider>().yandexAccessToken!);
    }

    if (url != null) {
      final mediaItem = MediaItem(
        id: url,
        title: _currentAudio!.title,
        artist: _currentAudio!.artist,
        artUri: Uri.parse(_currentAudio!.coverUrl ?? ''),
      );
      await _audioHandler.playMediaItem(mediaItem);
      await _audioHandler.play();
    }
    notifyListeners();
  }

  void stop() {
    _audioHandler.stop();
    notifyListeners();
  }
}

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _audioPlayer;

  AudioPlayerHandler(this._audioPlayer) {
    _audioPlayer.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_audioPlayer.processingState]!,
        playing: _audioPlayer.playing,
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
        speed: _audioPlayer.speed,
      ));
    });

    _audioPlayer.durationStream.listen((duration) {
      mediaItem.add(mediaItem.value?.copyWith(
        duration: duration ?? Duration.zero,
      ));
    });

    _audioPlayer.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
      updatePosition: position,
      ));
    });
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 1);
    int attempt = 0;
    bool success = false;
    while (attempt < maxRetries && !success) {
      try {
        await _audioPlayer.setUrl(mediaItem.id);
        success = true;
      }
      catch (e) {
        attempt++;
        print('Attempt $attempt failed with error: $e');
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        }
        else {
          print('Max retries reached. Skipping this track.');
          return;
        }
      }
    }
    
    if (success) {
      Duration? duration;
      while (duration == null) {
        duration = _audioPlayer.duration;
        await Future.delayed(const Duration(milliseconds: 100));
      }
    this.mediaItem.add(mediaItem.copyWith(duration: duration));
    }
  }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> stop() => _audioPlayer.stop();

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  Future<void> setLoopMode(LoopMode loopMode) async {
    _audioPlayer.setLoopMode(loopMode);
  }
}