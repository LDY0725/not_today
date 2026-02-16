import 'package:dio/dio.dart';
import '../api_exception.dart';

class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      if (data['code'] == 200 || data['status'] == 'success') {
        response.data = data['data'] ?? data['result'];
        handler.next(response);
      } else {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: ApiException.fromDioError(data),
          ),
        );
      }
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode ?? 0;
      final data = error.response!.data;

      ApiException exception;
      if (data is Map<String, dynamic>) {
        exception = ApiException.fromDioError(data);
      } else {
        exception = ApiException(
          message: _getErrorMessage(statusCode),
          code: statusCode,
        );
      }

      handler.next(
        DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          error: exception,
        ),
      );
    } else {
      handler.next(
        DioException(
          requestOptions: error.requestOptions,
          error: ApiException(message: error.message ?? '网络连接异常', code: -1),
        ),
      );
    }
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '禁止访问';
      case 404:
        return '请求的资源不存在';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      default:
        return '请求失败';
    }
  }
}
