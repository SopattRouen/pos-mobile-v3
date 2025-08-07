// =======================>> Third-party Packages
import 'package:dio/dio.dart';

// =======================>> Local Utilities
import 'package:calendar/utils/dio.client.dart';
import 'package:calendar/utils/help_util.dart';

// =======================>> Shared Components
import '../shared/error/error_type.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await DioClient.dio.post(
        "/account/auth/login",
        data: {
          "username": username,
          "password": password,
          "platform": "Mobile",
        },
      );
      return response.data;
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

  Future<Map<String, dynamic>> switchRole({
    required String defRoleId,
    required String swRoleId,
  }) async {
    try {
      final response = await DioClient.dio.post(
        "/account/auth/switch?role_id=$defRoleId",
        data: {"role_id": swRoleId},
      );
      print("🔍 Raw API Response: ${response.data}");
      if (response.data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format: Expected Map<String, dynamic>',
        );
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print("❌ DioException in switchRole: ${e.response?.data ?? e.message}");
      throw Exception(
        'Failed to switch role: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      print("❌ Unexpected error in switchRole: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? imageBase64,
  }) async {
    try {
      final response = await DioClient.dio.put(
        "/account/profile/update",
        data: {
          "name": name,
          "email": email,
          "phone": phone,
          if (imageBase64 != null) "avatar": imageBase64,
        },
      );
      print("🔍 Update Profile Response: ${response.data}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print(
        "❌ DioException in updateProfile: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        'Failed to update profile: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      print("❌ Unexpected error in updateProfile: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePassword({
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await DioClient.dio.put(
        "/account/profile/update-password",
        data: {"password": password, "confirm_password": confirmPassword},
      );
      print("🔍 Update Password Response: ${response.data}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print(
        "❌ DioException in updatePassword: ${e.response?.data ?? e.message}",
      );
      throw Exception(
        'Failed to update password: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      print("❌ Unexpected error in updatePassword: $e");
      rethrow;
    }
  }
}
