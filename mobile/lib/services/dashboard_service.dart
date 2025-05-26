import 'package:calendar/models/response_structure_model.dart';
import 'package:calendar/shared/error/error_type.dart';
import 'package:calendar/utils/dio.client.dart';
import 'package:calendar/utils/help_util.dart';
import 'package:dio/dio.dart';

class DashboardService {
  // Future<ResponseStructure<PaginationStructure<Map<String, dynamic>>>>
  //     request() async {
  //   try {
  //     final response = await DioClient.dio.get(
  //       "/admin/dashboard",
  //     );
  //     return ResponseStructure<
  //         PaginationStructure<Map<String, dynamic>>>.fromJson(
  //       response.data as Map<String, dynamic>,
  //       dataFromJson: (json) =>
  //           PaginationStructure<Map<String, dynamic>>.fromJson(
  //         json,
  //         resultFromJson: (item) => item,
  //       ),
  //     );
  //   } on DioException catch (dioError) {
  //     if (dioError.response != null) {
  //       printError(
  //         errorMessage: ErrorType.requestError,
  //         statusCode: dioError.response!.statusCode,
  //       );
  //       throw Exception(ErrorType.requestError);
  //     } else {
  //       printError(
  //         errorMessage: ErrorType.networkError,
  //         statusCode: null,
  //       );
  //       throw Exception(ErrorType.networkError);
  //     }
  //   } catch (e) {
  //     printError(errorMessage: 'Something went wrong.', statusCode: 500);
  //     throw Exception(ErrorType.unexpectedError);
  //   }
  // }
  Future<ResponseStructure<Map<String, dynamic>>> getData() async {
    try {
      final response = await DioClient.dio.get("/admin/dashboard");
      return ResponseStructure<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        dataFromJson: (json) => json,
      );
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        printError(
          errorMessage: ErrorType.requestError,
          statusCode: dioError.response!.statusCode,
        );
        throw Exception(ErrorType.requestError);
      } else {
        printError(errorMessage: ErrorType.networkError, statusCode: null);
        throw Exception(ErrorType.networkError);
      }
    } catch (e) {
      printError(errorMessage: 'Something went wrong.', statusCode: 500);
      throw Exception(ErrorType.unexpectedError);
    }
  }
}
