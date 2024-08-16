import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier{
  String? _yandexAccessToken;
  String? get yandexAccessToken => _yandexAccessToken;
  void setYandexAccessToken(String token) {
    _yandexAccessToken = token;
    notifyListeners();
  }
}