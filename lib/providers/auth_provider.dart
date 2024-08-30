import 'package:all_in_music/api/vk_api/vk_api.dart';
import 'package:all_in_music/api/yandex_api/yandex_api.dart';
import 'package:all_in_music/providers/audio_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class AuthProvider with ChangeNotifier{
  final _storage = const FlutterSecureStorage();

  String? _yandexAccessToken;
  String? _vkAccessToken;

  String? get yandexAccessToken => _yandexAccessToken;
  String? get vkAccessToken => _vkAccessToken;

  bool _isSync = false;
  bool get isSync => _isSync;

  Future<void> loadTokens() async {
    _vkAccessToken = await _storage.read(key: 'vkAccessToken');
    _yandexAccessToken = await _storage.read(key: 'yandexAccessToken');
    notifyListeners();
  }

  Future<void> setYandexAccessToken(String token) async {
    _yandexAccessToken = token;
    await _storage.write(key: 'yandexAccessToken', value: token);
    notifyListeners();
  }

  Future<void> setVkAccessToken(String token) async {
    _vkAccessToken = token;
    await _storage.write(key: 'vkAccessToken', value: token);
    notifyListeners();
  }

  Future<void> deleteYandexAccessToken() async {
    _yandexAccessToken = null;
    await _storage.delete(key: 'yandexAccessToken');
    notifyListeners();
  }

  Future<void> deleteVkAccessToken() async {
    _vkAccessToken = null;
    await _storage.delete(key: 'vkAccessToken');
    notifyListeners();
  }

  Future<void> syncTracks(BuildContext context) async {
    _isSync = true;

    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    await audioProvider.clearTracks();

    if (_vkAccessToken != null) {
      try {
        final vkTracks = await fetchAudio(_vkAccessToken!);
        audioProvider.updateAudioList(vkTracks);
      }
      catch (e) {
        print('Ошибка при синхронизации с ВК: $e');
      }
    }

    if (_yandexAccessToken != null) {
      try {
        final yandexUserId = await getYandexUserId(_yandexAccessToken!);
        final yandexTracks = await getYandexFavorites(_yandexAccessToken!, yandexUserId!);
        audioProvider.updateAudioList(yandexTracks);
      }
      catch (e) {
        print('Ошибка при синхронизации с Яндекс Музыкой: $e');
      }
    }

    _isSync = false;
  }
}