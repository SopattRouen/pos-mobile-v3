
import 'package:calendar/services/product_service.dart';
import 'package:calendar/utils/dio.client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CreateProductProvider extends ChangeNotifier {
  // Fields
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _dataSetup;
  Map<String, dynamic>? _createdProduct; // Store the created/updated product response
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
  CreateProductProvider() {
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

  Future<void> getProductDetails(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await DioClient.dio.get("/admin/products/$id");
      _productDetails = response.data as Map<String, dynamic>;
      _error = null;
    } on DioException catch (e) {
      _error = e.response?.data['message']?.toString() ?? "Failed to fetch product details.";
    } catch (e) {
      _error = "An unexpected error occurred.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProducts({
    required String name,
    required String code,
    required int typeId,
    required int price,
    required String image,
  }) async {
    _isLoading = true;
    _error = null; // Reset error before starting
    _createdProduct = null; // Reset created product
    notifyListeners();
    try {
      final response = await DioClient.dio.post(
        "/admin/products",
        data: {
          'name': name,
          'code': code,
          'type_id': typeId.toString(),
          'unit_price': price.toString(),
          'image': "data:image/png;base64,$image",
        },
      );
      _createdProduct = response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _error = e.response?.data['message']?.toString() ?? "Failed to create product.";
    } catch (e) {
      _error = "An unexpected error occurred.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String code,
    required int typeId,
    required int price,
    String? image,
  }) async {
    _isLoading = true;
    _error = null; // Reset error before starting
    _createdProduct = null; // Reset created product
    notifyListeners();
    try {
      final data = {
        'name': name,
        'code': code,
        'type_id': typeId.toString(),
        'unit_price': price.toString(),
      };
      // Only include image if provided
      if (image != null) {
        data['image'] = "data:image/png;base64,$image";
      }
      final response = await DioClient.dio.put(
        "/admin/products/$id",
        data: data,
      );
      _createdProduct = response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _error = e.response?.data['message']?.toString() ?? "Failed to update product.";
    } catch (e) {
      _error = "An unexpected error occurred.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}