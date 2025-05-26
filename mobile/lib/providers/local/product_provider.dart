import 'package:calendar/models/pagination_structure_model.dart';
import 'package:calendar/models/response_structure_model.dart';
import 'package:calendar/services/product_service.dart';
import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  // Feilds
  bool _isLoading = false;
  String? _error;
  ResponseStructure<PaginationStructure<Map<String, dynamic>>>? _productData;
  ResponseStructure<Map<String, dynamic>>? _productType;

  // Services
  final ProductService _service = ProductService();
  // final CreateRequestService _createRequestService = CreateRequestService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  ResponseStructure<PaginationStructure<Map<String, dynamic>>>? get productData =>
      _productData;
  ResponseStructure<Map<String, dynamic>>? get productType => _productType;

  // Setters

  // Initialize
  ProductProvider() {
    getHome();
  }

  // Functions
  Future<void> getHome({
    String? key,
    
    String? sort,
    String? order,
    String? limit,
    String? page,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _service.getData(
        key: key,
        sortBy: sort,
        order: order,
        limit: limit,
        page: page,
      );
      final res = await _service.getProductType();
      // final res = await _createRequestService.dataSetup();
      // _dataSetup = res;
      _productType =res;
      _productData = response;
    } catch (e) {
      _error = "Invalid Credential.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
