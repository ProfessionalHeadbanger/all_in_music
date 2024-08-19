import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier{
  final _storage = const FlutterSecureStorage();

  String? _yandexAccessToken;
  String? _vkAccessToken;

  String? get yandexAccessToken => _yandexAccessToken;
  String? get vkAccessToken => _vkAccessToken;

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
}