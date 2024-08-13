import 'package:all_in_music/models/audio_model.dart';
import 'package:flutter/material.dart';

class AudioProvider with ChangeNotifier {
  final List<Audio> _audioList = [];
  
  List<Audio> get audioList => _audioList;

  void updateAudioList(List<Audio> newAudioList) {
    for (var newAudio in newAudioList) {
      bool isDublicate = _audioList.any((audio) => 
        audio.title == newAudio.title && 
        audio.artist == newAudio.artist
      );
      if (!isDublicate) {
        _audioList.add(newAudio);
      }
      else {
        int index = _audioList.indexWhere((audio) => 
          audio.title == newAudio.title &&
          audio.artist == newAudio.artist
        );
        _audioList[index].sources.addAll(newAudio.sources);
      }
    }

    notifyListeners();
  }
}