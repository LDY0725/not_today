class ApiException implements Exception {
  final String message;
  final int? code;
  final dynamic data;

  ApiException({required this.message, this.code, this.data});

  @override
  String toString() {
    return 'ApiException(code: $code, message: $message, data: $data)';
  }

  factory ApiException.fromDioError(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    if (error is Map<String, dynamic>) {
      return ApiException(
        message: error['message'] ?? error['msg'] ?? '请求失败',
        code: error['code'] ?? error['status'],
        data: error['data'],
      );
    }

    return ApiException(message: error.toString(), code: null);
  }
}
