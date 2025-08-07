// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:dio/dio.dart';

// =======================>> Providers Components
import 'package:calendar/providers/global/network_provider.dart';
import 'package:provider/provider.dart';


class NetworkInterceptor extends Interceptor {
  final BuildContext context;

  NetworkInterceptor(this.context);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final networkProvider = Provider.of<NetworkProvider>(context, listen: false);
      final isConnected = networkProvider.isConnected;

      if (!isConnected) {
        return handler.reject(DioException(
          requestOptions: options,
          error: 'No internet connection',
          type: DioExceptionType.connectionError,
        ));
      }

      return handler.next(options);
    } catch (e) {
      // Handle case where context might be invalid or provider not available
      print('NetworkInterceptor error: $e');
      return handler.next(options); // Continue with request if provider check fails
    }
  }
}