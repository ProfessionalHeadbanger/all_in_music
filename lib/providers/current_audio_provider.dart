import 'package:all_in_music/api/yandex_api/yandex_api.dart';
import 'package:all_in_music/models/audio_model.dart';
import 'package:all_in_music/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class CurrentAudioProvider with ChangeNotifier {
  Audio? _currentAudio;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Audio> _audioList = [];
  List<Audio> _shuffledAudioList = [];
  bool _isShuffleMode = false;

  Audio? get currentAudio => _currentAudio;
  AudioPlayer? get audioPlayer => _audioPlayer;

  void setAudio(Audio audio) {
    _currentAudio = audio;
    notifyListeners();
  }

  void setAudioList(List<Audio> audioList) {
    _audioList = audioList;
    _shuffledAudioList = List<Audio>.from(_audioList);
    _shuffledAudioList.shuffle();
  }

  void toggleShuffleMode() {
    _isShuffleMode = !_isShuffleMode;
    notifyListeners();
  }

  Future<void> playPreviousTrack(BuildContext context) async {
    if (_isShuffleMode) {
      final currentIndex = _shuffledAudioList.indexOf(_currentAudio!);
      final previousIndex = (currentIndex - 1 + _shuffledAudioList.length) % _shuffledAudioList.length;
      _currentAudio = _shuffledAudioList[previousIndex];
    } else {
      final currentIndex = _audioList.indexOf(_currentAudio!);
      final previousIndex = (currentIndex - 1 + _audioList.length) % _audioList.length;
      _currentAudio = _audioList[previousIndex];
    }

    await playAudio(context);
    notifyListeners();
  }

  Future<void> playNextTrack(BuildContext context) async {
    if (_isShuffleMode) {
      final currentIndex = _shuffledAudioList.indexOf(_currentAudio!);
      final nextIndex = (currentIndex + 1) % _shuffledAudioList.length;
      _currentAudio = _shuffledAudioList[nextIndex];
    } else {
      final currentIndex = _audioList.indexOf(_currentAudio!);
      final nextIndex = (currentIndex + 1) % _audioList.length;
      _currentAudio = _audioList[nextIndex];
    }

    await playAudio(context);
    notifyListeners();
  }

  Future<void> playAudio(BuildContext context) async {
    if (_currentAudio == null) return;
    if (_currentAudio!.sources.contains('VK')) {
      if (_currentAudio!.mp3Url != null && currentAudio!.mp3Url!.isNotEmpty) {
        await _audioPlayer.setUrl(_currentAudio!.mp3Url!);
        _audioPlayer.play();
      }
    } else {
      final mp3Url = await getTrackUrl(_currentAudio!.id, context.read<AuthProvider>().yandexAccessToken!);
      if (mp3Url != null) {
        await _audioPlayer.setUrl(mp3Url);
        _audioPlayer.play();
      } else {
        print('Failed to retrieve MP3 URL for Yandex Music track.');
      }
    }
    notifyListeners();
  }
}