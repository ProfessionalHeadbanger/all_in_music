import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkProvider with ChangeNotifier {
  bool _isConnected = true;
  List<ConnectivityResult> _connectivityResult = [ConnectivityResult.none];

  bool get isConnected => _isConnected;
  List<ConnectivityResult> get connectivityResult => _connectivityResult;

  NetworkProvider() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    List<ConnectivityResult> result;
    try {
      result = await Connectivity().checkConnectivity();
    }
    catch (e) {
      result = [ConnectivityResult.none];
    }
    _updateConnectionStatus(result);

    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    _connectivityResult = result;
    if (result.contains(ConnectivityResult.mobile) || 
          result.contains(ConnectivityResult.wifi) || 
          result.contains(ConnectivityResult.ethernet)) {
      _isConnected = true;
    }
    else {
      _isConnected = false;
    }
    notifyListeners();
  }
}