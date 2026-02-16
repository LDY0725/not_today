import 'package:dio/dio.dart';

class RequestInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    final token = _getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  String? _getToken() {
    return null;
  }
}
