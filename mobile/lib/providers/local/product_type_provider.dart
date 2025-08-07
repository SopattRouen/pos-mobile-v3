// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:dio/dio.dart';

// =======================>> Local Services
import 'package:calendar/services/product_type_service.dart';


class ProductTypeProvider extends ChangeNotifier {
  // Feilds
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _productType;

  // Services
  final ProductTypeService _service = ProductTypeService();
  // final CreateRequestService _createRequestService = CreateRequestService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  // Map<String, dynamic>? get productData => _productType;
  Map<String, dynamic>? get productType => _productType;

  // Setters

  // Initialize
  ProductTypeProvider() {
    getHome();
  }

  // Functions
  Future<void> getHome() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _service.getData();
      // final res = await _service.getProductType();
      // // final res = await _createRequestService.dataSetup();
      // // _dataSetup = res;
      _productType = response;
    } catch (e) {
      _error = "Invalid Credential.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.deleteProductType(id);
      if (_productType != null && _productType?['data'] is List) {
        _productType!['data'] =
            (_productType!['data'] as List)
                .where((product) => product['id'] != id)
                .toList();
      }
      _error = null;
      return true;
    } catch (e) {
      // For Dio
      if (e is DioError || e is DioException) {
        final response = (e as dynamic).response;
        if (response != null && response.data is Map<String, dynamic>) {
          _error = response.data['message'] ?? 'Failed to delete product.';
        } else {
          _error = 'Failed to delete product.';
        }
      }
      // Fallback for other types of exceptions
      else if (e is Map<String, dynamic>) {
        _error = e['message'] ?? 'Failed to delete product.';
      } else {
        _error = 'Failed to delete product.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
