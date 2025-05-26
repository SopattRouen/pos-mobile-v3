import 'package:calendar/models/pagination_structure_model.dart';
import 'package:calendar/models/response_structure_model.dart';
import 'package:calendar/services/sale_service.dart';
import 'package:flutter/material.dart';

class SaleProvider extends ChangeNotifier {
  // Feilds
  bool _isLoading = false;
  String? _error;
  ResponseStructure<PaginationStructure<Map<String, dynamic>>>? _saleData;
  ResponseStructure<Map<String, dynamic>>? _dataSetup;

  // Services
  final SaleService _saleService = SaleService();
  // final CreateRequestService _createRequestService = CreateRequestService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  ResponseStructure<PaginationStructure<Map<String, dynamic>>>? get saleData =>
      _saleData;
  ResponseStructure<Map<String, dynamic>>? get dataSetup => _dataSetup;

  // Setters

  // Initialize
  SaleProvider() {
    getHome();
  }

  // Functions
  Future<void> getHome({
    String? from,
    String? to,
    String? cashier,
    String? platform,
    String? sort,
    String? order,
    String? limit,
    String? page,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _saleService.getData(
        from: from,
        to: to,
        cashier: cashier,
        platform: platform,
        sort: sort,
        order: order,
        limit: limit,
        page: page,
      );
      // final res = await _createRequestService.dataSetup();
      // _dataSetup = res;
      _saleData = response;
    } catch (e) {
      _error = "Invalid Credential.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
