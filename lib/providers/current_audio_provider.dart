import 'package:all_in_music/models/audio_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class CurrentAudioProvider with ChangeNotifier {
  Audio? _currentAudio;
  AudioPlayer? _audioPlayer;

  Audio? get currentAudio => _currentAudio;
  AudioPlayer? get audioPlayer => _audioPlayer;

  void setAudio(Audio audio, AudioPlayer player) {
    _currentAudio = audio;
    _audioPlayer = player;
    notifyListeners();
  }
}