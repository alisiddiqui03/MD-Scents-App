import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/app/core/config/app_config.dart';
import 'package:flutter_application_1/app/core/services/storage_services.dart';

class ApiService {
  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {"Accept": "application/json"},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            // ========== REQUEST PRINT ==========
            onRequest: (options, handler) {
              print("\n🚀 API REQUEST");
              print("Method: ${options.method}");
              print("URL: ${options.uri}");
              print("Headers: ${options.headers}");
              if (options.data != null) {
                print("Request Body:");
                try {
                  print(
                    const JsonEncoder.withIndent('  ').convert(options.data),
                  );
                } catch (e) {
                  print(options.data);
                }
              }
              print("─" * 50);

              // Token automatically add karna (pehle wala code)
              final token = StorageService.token;
              if (token != null && token.isNotEmpty) {
                options.headers["Authorization"] = "Bearer $token";
              }

              handler.next(options);
            },

            // ========== RESPONSE PRINT ==========
            onResponse: (response, handler) {
              print("\n✅ API RESPONSE");
              print("Status: ${response.statusCode}");
              print("URL: ${response.requestOptions.uri}");
              print("Response Data:");
              try {
                final prettyJson = const JsonEncoder.withIndent(
                  '  ',
                ).convert(response.data);
                print(prettyJson);
              } catch (e) {
                print(response.data);
              }
              print("═" * 60);

              handler.next(response);
            },

            // ========== ERROR PRINT ==========
            onError: (DioException e, handler) {
              print("\n❌ API ERROR");
              print("URL: ${e.requestOptions.uri}");
              print("Method: ${e.requestOptions.method}");
              if (e.response != null) {
                print("Status Code: ${e.response?.statusCode}");
                print("Error Response:");
                try {
                  final prettyJson = const JsonEncoder.withIndent(
                    '  ',
                  ).convert(e.response?.data);
                  print(prettyJson);
                } catch (_) {
                  print(e.response?.data);
                }
              } else {
                print("Error Message: ${e.message}");
              }
              print("═" * 60);

              handler.next(e);
            },
          ),
        );

  // Baaki methods same
  static Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    return await dio.get(endpoint, queryParameters: query);
  }

  static Future<Response> post(String endpoint, {dynamic data}) async {
    return await dio.post(endpoint, data: data);
  }
}
