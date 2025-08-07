// =======================>> Dart Core
import 'dart:async' show StreamSubscription;

// =======================>> Flutter Core
import 'package:flutter/foundation.dart';

// =======================>> Local Services
import 'package:calendar/services/network_service.dart';


class NetworkProvider with ChangeNotifier {
  bool _isConnected = true; // Default to true to avoid initial flicker
  bool _wasDisconnected = false;
  
  bool get isConnected => _isConnected;
  bool get connectionRestored => _wasDisconnected && _isConnected;

  final NetworkService _networkService;
  late StreamSubscription<bool> _connectionSubscription;

  NetworkProvider({required NetworkService networkService}) 
    : _networkService = networkService;

  Future<void> initialize() async {
    await _networkService.initialize();
    await checkConnection();
    
    // Listen for connection changes
    _connectionSubscription = _networkService.connectionStream.listen(
      (connected) => _updateConnectionStatus(connected),
      onError: (error) {
        debugPrint('Network stream error: $error');
        _updateConnectionStatus(false);
      },
    );
  }

  Future<bool> checkConnection() async {
    try {
      print("call me");
      final connected = await _networkService.isConnected;
      _updateConnectionStatus(connected);
      return connected;
    } catch (e) {
      debugPrint('Connection check failed: $e');
      _updateConnectionStatus(false);
      return false;
    }
  }

  void _updateConnectionStatus(bool newStatus) {
    if (newStatus != _isConnected) {
      _wasDisconnected = !newStatus; // Track if we were previously disconnected
      _isConnected = newStatus;
      notifyListeners();

      // Reset restoration status after showing
      if (connectionRestored) {
        Future.delayed(const Duration(seconds: 3), () {
          _wasDisconnected = false;
          notifyListeners();
        });
      }
    }
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }
}