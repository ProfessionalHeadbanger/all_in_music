import 'dart:math';

import 'package:all_in_music/models/audio_model.dart';

class PlaybackQueue {
  final List<Audio> _fullAudioList;
  List<Audio> _currentQueue = [];
  int _currentIndex = 0;
  bool _isShuffleMode = false;

  PlaybackQueue(this._fullAudioList);

  List<Audio> get currentQueue => _currentQueue;
  int get currentIndex => _currentIndex;
  Audio get currentAudio => _currentQueue[_currentIndex];

  void createQueueFrom(int startIndex) {
    _currentQueue = [];
    _currentIndex = 0;
    _isShuffleMode = false;

    int i = 0;
    while (i < 100 && startIndex + i < _fullAudioList.length) {
      _currentQueue.add(_fullAudioList[startIndex + i]);
      i++;
    }

    int remainingSlots = 100 - _currentQueue.length;
    if (remainingSlots > 0) {
      for (int j = 0; j < remainingSlots && j < startIndex; j++) {
        _currentQueue.add(_fullAudioList[j]);
      }
    }
  }

  void createShuffledQueue() {
    _currentQueue = [];
    _currentIndex = 0;
    _isShuffleMode = true;

    List<Audio> shuffledList = List<Audio>.from(_fullAudioList);
    shuffledList.shuffle(Random());

    for (int i = 0; i < 100 && i < shuffledList.length; i++) {
      _currentQueue.add(shuffledList[i]);
    }
  }

  void advanceQueue() {
    _currentIndex++;
    if (_currentIndex >= _currentQueue.length) {
      if (_isShuffleMode) {
        createShuffledQueue();
      } else {
        if (_currentQueue.last == _fullAudioList.last) {
          createQueueFrom(0);
        } else {
          int nextStartIndex = _fullAudioList.indexOf(_currentQueue.last) + 1;
          createQueueFrom(nextStartIndex);
        }
      }
    }
  }

  bool hasNext() {
    return _currentIndex < _currentQueue.length - 1;
  }
}
