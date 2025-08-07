// =======================>> Third-party Packages
import 'package:dio/dio.dart';

// =======================>> Local Models
import 'package:calendar/models/response_structure_model.dart';

// =======================>> Shared Components
import 'package:calendar/shared/error/error_type.dart';

// =======================>> Local Utilities
import 'package:calendar/utils/dio.client.dart';
import 'package:calendar/utils/help_util.dart';


class DashboardService {
  Future<ResponseStructure<Map<String, dynamic>>> getData() async {
    try {
      print('🌐 DashboardService: Making API call to /admin/dashboard');
      
      final response = await DioClient.dio.get("/admin/dashboard/?thisMonth=2024-11-5");
      
      print('✅ DashboardService: API response received');
      print('📊 DashboardService: Status code: ${response.statusCode}');
      print('📊 DashboardService: Response data type: ${response.data.runtimeType}');
      
      // Add null check for response data
      if (response.data == null) {
        throw Exception('Response data is null');
      }
      
      // Ensure response.data is a Map
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Response data is not a Map<String, dynamic>');
      }
      
      final responseStructure = ResponseStructure<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        dataFromJson: (json) {
          print('📊 DashboardService: Processing response JSON');
          print('📊 DashboardService: JSON keys: ${json.keys}');
          return json;
        },
      );
      
      print('✅ DashboardService: Response structure created successfully');
      return responseStructure;
      
    } on DioException catch (dioError) {
      print('❌ DashboardService: DioException occurred');
      print('❌ DashboardService: Error type: ${dioError.type}');
      print('❌ DashboardService: Error message: ${dioError.message}');
      
      if (dioError.response != null) {
        print('❌ DashboardService: Response status code: ${dioError.response!.statusCode}');
        print('❌ DashboardService: Response data: ${dioError.response!.data}');
        
        printError(
          errorMessage: ErrorType.requestError,
          statusCode: dioError.response!.statusCode,
        );
        throw Exception('Request failed with status ${dioError.response!.statusCode}');
      } else {
        printError(errorMessage: ErrorType.networkError, statusCode: null);
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print('❌ DashboardService: Unexpected error occurred');
      print('❌ DashboardService: Error: $e');
      print('❌ DashboardService: Error type: ${e.runtimeType}');
      
      printError(errorMessage: 'Something went wrong: $e', statusCode: 500);
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}