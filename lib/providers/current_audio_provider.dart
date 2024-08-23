import 'package:all_in_music/models/audio_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class CurrentAudioProvider with ChangeNotifier {
  Audio? _currentAudio;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Audio? get currentAudio => _currentAudio;
  AudioPlayer get audioPlayer => _audioPlayer;

  void setAudio(Audio audio) async {
    _currentAudio = audio;
    await _audioPlayer.setUrl(audio.mp3Url!);
    _audioPlayer.play();
    notifyListeners();
  }

  Future<void> playNextTrack(List<Audio> audioList) async {
    if (_currentAudio != null) {
      final currentIndex = audioList.indexOf(_currentAudio!);
      final nextIndex = (currentIndex + 1) % audioList.length;
      setAudio(audioList[nextIndex]);
    }
  }

  Future<void> playPreviousTrack(List<Audio> audioList) async {
    if (_currentAudio != null) {
      final currentIndex = audioList.indexOf(_currentAudio!);
      final previousIndex = (currentIndex - 1 + audioList.length) % audioList.length;
      setAudio(audioList[previousIndex]);
    }
  }
}
