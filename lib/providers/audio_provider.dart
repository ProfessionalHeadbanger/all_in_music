import 'package:all_in_music/models/audio_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioProvider with ChangeNotifier {
  List<Audio> _audioList = [];
  
  List<Audio> get audioList => _audioList;

  AudioProvider() {
    loadTracksFromStorage();
  }

  void updateAudioList(List<Audio> newAudioList) async {
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
        _updateExistingAudio(_audioList[index], newAudio);
      }
    }
    
    await _saveTracksToStorage();
    notifyListeners();
  }

  void _updateExistingAudio(Audio existingAudio, Audio newAudio) {
    existingAudio.sources.addAll(newAudio.sources);

    if (existingAudio.mp3Url == null && newAudio.mp3Url != null) {
      existingAudio.mp3Url = newAudio.mp3Url;
    }

    if (existingAudio.coverUrl == null && newAudio.coverUrl != null) {
      existingAudio.coverUrl = newAudio.coverUrl;
    }

    newAudio.trackLinks.forEach((key, value) {
      existingAudio.trackLinks[key] = value;
    });
  }

 void removeSource(String source) async {
    _audioList = _audioList.map((audio) {
      if (audio.sources.contains(source)) {
        if (audio.sources.length > 1) {
          final updatedSources = Set<String>.from(audio.sources)..remove(source);
          final updatedTrackLinks = Map<String, String>.from(audio.trackLinks)..remove(source);
          return audio.copyWith(sources: updatedSources, trackLinks: updatedTrackLinks);
        } else {
          return null;
        }
      }
      return audio;
    }).where((audio) => audio != null).cast<Audio>().toList();

    await _saveTracksToStorage();
    notifyListeners();
  }

  Future<void> _saveTracksToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tracksJson = _audioList.map((audio) => audio.toJson()).toList();
    await prefs.setStringList('savedTracks', tracksJson);
  }

  Future<void> loadTracksFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? tracksJson = prefs.getStringList('savedTracks');

    if (tracksJson != null) {
      _audioList.clear();
      _audioList.addAll(tracksJson.map((jsonStr) => Audio.fromJson(jsonStr)).toList());
      notifyListeners();
    }
  }
}