import 'package:all_in_music/api/vk_api/models/audio_model.dart';
import 'package:flutter/material.dart';

class AudioProvider with ChangeNotifier {
  List<Audio> _audioList = [];
  
  List<Audio> get audioList => _audioList;

  void updateAudioList(List<Audio> newAudioList) {
    _audioList = newAudioList;
    notifyListeners();
  }
}