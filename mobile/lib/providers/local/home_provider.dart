import 'package:calendar/models/response_structure_model.dart';
import 'package:calendar/services/home_service.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  // Fields
  bool _isLoading = false;
  String? _error;
  ResponseStructure<Map<String, dynamic>>? _data;

  // Services
  final DashboardService _dashboardService = DashboardService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  ResponseStructure<Map<String, dynamic>>? get data => _data;

  // Initialize
  HomeProvider() {
    getHome();
  }

  // Functions
  Future<void> getHome() async {
    _isLoading = true;
    _error = null; // Clear previous error
    notifyListeners();
    
    try {
      print('🔄 HomeProvider: Starting API call...');
      final response = await _dashboardService.getData();
      
      print('✅ HomeProvider: API call successful');
      print('📊 HomeProvider: Response data keys: ${response.data.keys}');
      
      _data = response;
      _error = null; // Ensure error is cleared on success
      
      print('✅ HomeProvider: Data set successfully');
      
    } catch (e) {
      print('❌ HomeProvider: Error occurred - $e');
      _error = "Failed to load dashboard data: ${e.toString()}";
      _data = null;
    } finally {
      _isLoading = false;
      print('🏁 HomeProvider: Loading complete - isLoading: $_isLoading, hasData: ${_data != null}, error: $_error');
      notifyListeners();
    }
  }
}