import 'package:calendar/models/pagination_structure_model.dart';
import 'package:calendar/models/response_structure_model.dart';
import 'package:calendar/shared/error/error_type.dart';
import 'package:calendar/utils/dio.client.dart';
import 'package:calendar/utils/help_util.dart';
import 'package:dio/dio.dart';

class SaleService {
    Future<ResponseStructure<PaginationStructure<Map<String, dynamic>>>>
      getData(
        {
          required String? from ,
          required String? to,
          required String? cashier,
          required String? platform,
          required String? sort,
          required String? order,
          required String? limit,
          required String? page,
        }
      ) async {
    try {
      final response = await DioClient.dio.get(
        "/admin/sales",
      );
      return ResponseStructure<
          PaginationStructure<Map<String, dynamic>>>.fromJson(
        response.data as Map<String, dynamic>,
        dataFromJson: (json) =>
            PaginationStructure<Map<String, dynamic>>.fromJson(
          json,
          resultFromJson: (item) => item,
        ),
      );
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


}
