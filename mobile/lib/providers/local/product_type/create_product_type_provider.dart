// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:dio/dio.dart';

// =======================>> Local Services
import 'package:calendar/services/product_service.dart';
import 'package:calendar/utils/dio.client.dart';

class CreateProductTypeProvider extends ChangeNotifier {
  // Fields
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _dataSetup;
  Map<String, dynamic>?
  _createdProduct; // Store the created/updated product response
  Map<String, dynamic>? _productDetails; // Store fetched product details

  // Services
  final ProductService _service = ProductService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get dataSetup => _dataSetup;
  Map<String, dynamic>? get createdProduct => _createdProduct;
  Map<String, dynamic>? get productDetails => _productDetails;

  // Initialize
  CreateProductTypeProvider() {
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
      final response = await _service.dataSetup();
      _dataSetup = response;
    } catch (e) {
      _error = "Invalid Credential.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProductsType({
    required String name,
    required String image,
  }) async {
    _isLoading = true;
    _error = null; // Reset error before starting
    _createdProduct = null; // Reset created product
    notifyListeners();
    try {
      final response = await DioClient.dio.post(
        "/admin/products/types",
        data: {'name': name, 'image': "data:image/png;base64,$image"},
      );
      _createdProduct = response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _error =
          e.response?.data['message']?.toString() ??
          "Failed to create product.";
    } catch (e) {
      _error = "An unexpected error occurred.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future updateProductType({
    required String id,
    required String name,
    String? image, // Should be base64 string
  }) async {
    _isLoading = true;
    _error = null; // Reset error before starting
    _createdProduct = null; // Reset created product
    notifyListeners();
    try {
      final data = {'name': name};
      // Only include image if provided
      if (image != null) {
        data['image'] = image; // Already base64 encoded
      }
      final response = await DioClient.dio.put(
        "/admin/products/types/$id",
        data: data,
      );
      _createdProduct = response.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      _error =
          e.response?.data['message']?.toString() ??
          "Failed to update product.";
    } catch (e) {
      _error = "An unexpected error occurred.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
