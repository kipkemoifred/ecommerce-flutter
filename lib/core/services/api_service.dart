import 'package:dio/dio.dart';

class ApiService {
  static late final Dio _dio;

  static void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://dummyjson.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    );
  }

  static Dio get client => _dio;

  /// Example REST API method using Dio: Fetch external catalog products
  static Future<List<dynamic>> fetchExternalProducts({int limit = 10}) async {
    try {
      final response = await _dio.get('/products', queryParameters: {'limit': limit});
      if (response.statusCode == 200 && response.data != null) {
        return response.data['products'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      // In case of network errors or offline mode
      return [];
    }
  }

  /// Example REST API method using Dio: Search external products
  static Future<List<dynamic>> searchExternalProducts(String query) async {
    try {
      final response = await _dio.get('/products/search', queryParameters: {'q': query});
      if (response.statusCode == 200 && response.data != null) {
        return response.data['products'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
