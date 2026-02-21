import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WechatShareUtils {
  static const String _wechatAppId = 'wxfae9158c846191a0';

  static Future<bool> isWeChatInstalled() async {
    try {
      final wechatUrl = Uri.parse('weixin://');
      return await canLaunchUrl(wechatUrl);
    } catch (e) {
      return false;
    }
  }

  static Future<void> openWeChatDownloadPage() async {
    final url = Uri.parse('https://weixin.qq.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static Future<Uint8List?> captureWidgetToImageBytes({
    required GlobalKey repaintBoundaryKey,
    required BuildContext context,
  }) async {
    try {
      final RenderRepaintBoundary? repaintBoundary =
          repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (repaintBoundary == null) {
        return null;
      }

      await Future.delayed(const Duration(milliseconds: 100));

      final image = await repaintBoundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  static Future<String?> captureWidgetToTempFilePath({
    required GlobalKey repaintBoundaryKey,
    required BuildContext context,
    String fileName = 'share_card',
  }) async {
    try {
      final RenderRepaintBoundary? repaintBoundary =
          repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (repaintBoundary == null) {
        return null;
      }

      await Future.delayed(const Duration(milliseconds: 100));

      final image = await repaintBoundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        return null;
      }

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final String path =
          '${directory.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(imageBytes);

      return path;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> shareToWechat({
    required GlobalKey repaintBoundaryKey,
    required BuildContext context,
    String? text,
    String fileName = 'share_card',
  }) async {
    try {
      final isInstalled = await isWeChatInstalled();

      if (!isInstalled) {
        _showWechatNotInstalledSnackbar();
        return false;
      }

      final filePath = await captureWidgetToTempFilePath(
        repaintBoundaryKey: repaintBoundaryKey,
        context: context,
        fileName: fileName,
      );

      if (filePath == null) {
        _showErrorSnackbar('生成分享图片失败');
        return false;
      }

      final XFile xFile = XFile(filePath);

      await Share.shareXFiles(
        [xFile],
        text: text ?? '不干了 - 职业勋章',
      );

      return true;
    } catch (e) {
      print('分享失败: $e');
      _showErrorSnackbar('分享失败: $e');
      return false;
    }
  }

  static Future<bool> shareImageToWechat({
    required Uint8List imageBytes,
    String? text,
    String fileName = 'share_card',
  }) async {
    try {
      final isInstalled = await isWeChatInstalled();

      if (!isInstalled) {
        _showWechatNotInstalledSnackbar();
        return false;
      }

      final directory = await getApplicationDocumentsDirectory();
      final String path =
          '${directory.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(imageBytes);

      final XFile xFile = XFile(path);

      await Share.shareXFiles(
        [xFile],
        text: text ?? '不干了 - 职业勋章',
      );

      return true;
    } catch (e) {
      print('分享失败: $e');
      _showErrorSnackbar('分享失败: $e');
      return false;
    }
  }

  static void _showWechatNotInstalledSnackbar() {
    Get.closeCurrentSnackbar();
    Get.snackbar(
      '未安装微信',
      '请先安装微信后再分享',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  static void _showErrorSnackbar(String message) {
    Get.closeCurrentSnackbar();
    Get.snackbar(
      '分享失败',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  static void _showSuccessSnackbar() {
    Get.closeCurrentSnackbar();
    Get.snackbar(
      '分享成功',
      '请选择分享方式',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4a3621),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
