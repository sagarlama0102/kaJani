import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/api/api_endpoints.dart';
import 'package:kajani/core/services/storage/token_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenService = ref.read(tokenServiceProvider);
  return ApiClient(tokenService: tokenService);
});

class ApiClient {
  late final Dio _dio;
  final TokenService _tokenService;

  ApiClient({required TokenService tokenService})
      : _tokenService = tokenService {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(_tokenService));

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return _dio.post(
      path,
      data: formData,
      options: Options(
      contentType: 'multipart/form-data',
      headers: options?.headers,
    ),
      onSendProgress: onSendProgress,
    );
  }
}

// ─── Auth Interceptor ─────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  final TokenService _tokenService; // ✅ use TokenService not FlutterSecureStorage

  final List<String> _publicEndpoints = [
    ApiEndpoints.register,
    ApiEndpoints.login,
    ApiEndpoints.googleSignIn,
  ];

  _AuthInterceptor(this._tokenService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final isPublic = _publicEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (!isPublic) {
      final token = _tokenService.getToken(); // ✅ sync, no await needed
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _tokenService.deleteToken(); // ✅ using TokenService not FlutterSecureStorage
    }
    handler.next(err);
  }
}