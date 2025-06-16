

import 'package:calendar/shared/error/error_type.dart';
import 'package:calendar/utils/dio.client.dart';
import 'package:calendar/utils/help_util.dart';
import 'package:dio/dio.dart';

class SaleService {
  Future<Map<String, dynamic>> getData({
    String? from,
    String? to,
    String? cashier,
    String? platform,
    String? sort,
    String? order,
    String? limit,
    String? page,
  }) async {
    try {
      final response = await DioClient.dio.get(
        "/admin/sales?limit=1000&page=1",
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          if (cashier != null) 'cashier': cashier,
          if (platform != null) 'platform': platform,
          if (sort != null) 'sort': sort,
          if (order != null) 'order': order,
          // if (limit != null) 'limit':limit
        },
      );

      // log("Response: ${response.data}");

      return response.data as Map<String, dynamic>;
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        printError(
          errorMessage: ErrorType.requestError,
          statusCode: dioError.response!.statusCode,
        );
        throw Exception(ErrorType.requestError);
      } else {
        printError(
          errorMessage: ErrorType.networkError,
          statusCode: null,
        );
        throw Exception(ErrorType.networkError);
      }
    } catch (e) {
      printError(errorMessage: 'Something went wrong.', statusCode: 500);
      throw Exception(ErrorType.unexpectedError);
    }
  }
  Future<void> deleteSale(int id) async {
    try {
      await DioClient.dio.delete("/admin/sales/$id");
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}