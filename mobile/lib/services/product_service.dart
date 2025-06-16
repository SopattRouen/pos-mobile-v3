// import 'dart:developer';

// import 'package:calendar/shared/error/error_type.dart';
import 'package:calendar/utils/dio.client.dart';
// import 'package:calendar/utils/help_util.dart';
import 'package:dio/dio.dart';

class ProductService {
  Future<Map<String, dynamic>> dataSetup() async {
    try {
      final response = await DioClient.dio.get("/admin/products/setup-data");
      // log("${response}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getData({
    required String? key,
    required String? sortBy,
    required String? order,
    required String? limit,
    required String? page,
  }) async {
    try {
      final response = await DioClient.dio.get(
        "/admin/products?page=1&order=desc&sort_by=created_at&limit=20",
      );
      // log("${response}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDetailProduct({
    required String id
  }) async {
    try {
      final response = await DioClient.dio.get(
        "/admin/products/$id",
      );
      // log("${response}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
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
