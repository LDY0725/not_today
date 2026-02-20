import 'package:dio/dio.dart';
import 'api_exception.dart';
import 'interceptors/request_interceptor.dart';
import 'interceptors/response_interceptor.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _dio = Dio(_options)
      ..interceptors.addAll([
        RequestInterceptor(),
        ResponseInterceptor(),
      ]);
  }

  static late final Dio _dio;
  static const String _baseUrl = 'http://192.168.0.115:8080';

  static final BaseOptions _options = BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
    responseType: ResponseType.json,
  );

  static ApiClient get instance => _instance;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.error);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.error);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.error);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.error);
    }
  }

  void cancelRequests([CancelToken? cancelToken]) {
    cancelToken?.cancel('请求已取消');
  }

  Future<dynamic> checkin({
    required String userId,
    required String city,
    required String industry,
  }) async {
    try {
      final response = await _dio.post(
        '/api/nottoday/checkin',
        data: {
          'userId': userId,
          'city': city,
          'industry': industry,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.error);
    }
  }
}
