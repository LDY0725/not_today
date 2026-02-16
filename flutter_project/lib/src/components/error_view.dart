import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final dynamic data;
  final VoidCallback? onRetry;
  final String? retryText;
  final Widget? customIcon;

  const ErrorView({
    super.key,
    required this.message,
    this.data,
    this.onRetry,
    this.retryText = '重试',
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customIcon ??
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (data != null && data is String && data.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                data,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorView extends ErrorView {
  const NetworkErrorView({
    super.key,
    super.message = '网络连接失败',
    super.onRetry,
    super.retryText = '重新加载',
  });

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      message: message,
      customIcon: Icon(
        Icons.cloud_off,
        size: 64,
        color: Colors.grey[400],
      ),
      onRetry: onRetry,
      retryText: retryText,
    );
  }
}

class EmptyErrorView extends ErrorView {
  const EmptyErrorView({
    super.key,
    super.message = '暂无数据',
    super.customIcon,
    super.retryText,
    super.onRetry,
    super.data,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      message: message,
      customIcon: Icon(
        Icons.inbox,
        size: 64,
        color: Colors.grey[400],
      ),
      onRetry: onRetry,
      retryText: retryText,
      data: data,
    );
  }
}
