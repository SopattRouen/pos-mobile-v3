// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Local Services
import 'package:calendar/services/product_service.dart';


class ProductProvider extends ChangeNotifier {
  // Feilds
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _productData;
  Map<String, dynamic>? _productType;

  // Services
  final ProductService _service = ProductService();
  // final CreateRequestService _createRequestService = CreateRequestService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get productData => _productData;
  Map<String, dynamic>? get productType => _productType;

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
      // final res = await _service.getProductType();
      // // final res = await _createRequestService.dataSetup();
      // // _dataSetup = res;
      // _productType = res;
      _productData = response;
    } catch (e) {
      _error = "Invalid Credential.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Assuming ProductService has a delete method
      await _service.deleteProduct(id);
      // Update productData by removing the deleted product
      if (_productData != null && _productData?['data'] is List) {
        _productData!['data'] =
            (_productData!['data'] as List)
                .where((product) => product['id'] != id)
                .toList();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to delete product.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
