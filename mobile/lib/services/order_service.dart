// =======================>> Third-party Packages
import 'dart:convert';

import 'package:dio/dio.dart';

// =======================>> Local Utilities
import 'package:calendar/utils/dio.client.dart';
// import 'package:calendar/utils/help_util.dart';

// =======================>> Shared Components
// import 'package:calendar/shared/error/error_type.dart';

class OrderService {
  // Future<Map<String, dynamic>> dataSetup() async {
  //   try {
  //     final response = await DioClient.dio.get("/admin/products/setup-data");
  //     // log("${response}");
  //     return response.data as Map<String, dynamic>;
  //   } on DioException catch (_) {
  //     rethrow;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<Map<String, dynamic>> getData(
    // required String? key,
    // required String? sortBy,
    // required String? order,
    // required String? limit,
    // required String? page,
  ) async {
    try {
      final response = await DioClient.dio.get("/cashier/ordering/products");
      // log("${response}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> orderProduct({
    required List<Map<String, dynamic>> cart,
  }) async {
    try {
      final cartMap = <String, int>{};
      for (var item in cart) {
        if (item['id'] is! String || item['quantity'] is! int) {
          throw Exception('Invalid cart item format');
        }
        final id = item['id'] as String;
        final quantity = item['quantity'] as int;
        cartMap[id] = quantity;
      }
      final cartJson = jsonEncode(cartMap);
      final response = await DioClient.dio.post(
        "/cashier/ordering/order",
        data: {
          'cart': cartJson,
          'platform': 'Mobile',
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('DioException: ${e.message}, Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await DioClient.dio.delete("/admin/products/$id");
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
