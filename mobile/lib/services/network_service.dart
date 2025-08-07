// =======================>> Third-party Packages
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkService {
  // Singleton pattern
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final _connectivity = Connectivity();
  late final InternetConnectionChecker _connectionChecker;

  Future<void> initialize() async {
    _connectionChecker = InternetConnectionChecker.createInstance(
      checkInterval: const Duration(seconds: 10),
      checkTimeout: const Duration(seconds: 5),
    );
  }

  Future<bool> get isConnected async {
    // Check connectivity first
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    
    // Verify actual internet connection
    return await _connectionChecker.hasConnection;
  }

  Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.asyncMap((_) => isConnected);
  }
}