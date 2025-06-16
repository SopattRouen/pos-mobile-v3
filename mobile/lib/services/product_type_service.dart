// import 'dart:developer';

// import 'package:calendar/shared/error/error_type.dart';
import 'package:calendar/utils/dio.client.dart';
// import 'package:calendar/utils/help_util.dart';
import 'package:dio/dio.dart';

class ProductTypeService {

  Future<Map<String, dynamic>> getData() async {
    try {
      final response = await DioClient.dio.get(
        "/admin/products/types/data",
      );
      // log("${response}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Future<Map<String, dynamic>> getDetailProduct({
  //   required String id
  // }) async {
  //   try {
  //     final response = await DioClient.dio.get(
  //       "/admin/products/$id",
  //     );
  //     // log("${response}");
  //     return response.data as Map<String, dynamic>;
  //   } on DioException catch (_) {
  //     rethrow;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> deleteProductType(int id) async {
    try {
      await DioClient.dio.delete("/admin/products/types/$id");
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  
}
