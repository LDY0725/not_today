import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluwx/fluwx.dart';

class WechatShareUtils {
  static const String _wechatAppId = 'wxfae9158c846191a0';
  static bool _isInitialized = false;
  static Fluwx fluwx = Fluwx();

  static Future<void> _initialize() async {
    print('微信已安装1');
    // print(_isInitialized);
    // if (_isInitialized) return;

    final isInstalled = await fluwx.isWeChatInstalled;
    print('微信已安装2');
    if (isInstalled) {
      print('微信已安装2');
      fluwx.registerApi(
          appId: "wxfae9158c846191a0",
          universalLink: "https://little-bridge.com/buganle/aa/");

      _isInitialized = true;
    }
  }

  static Future<bool> isWeChatInstalled() async {
    try {
      return await fluwx.isWeChatInstalled;
    } catch (e) {
      return false;
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

  static Future<bool> shareImageToWechat(
      {required Uint8List imageBytes, required WeChatScene scene}) async {
    try {
      final isInstalled = await isWeChatInstalled();

      if (!isInstalled) {
        _showWechatNotInstalledSnackbar();
        return false;
      }

      await _initialize();

      final result = await fluwx.share(
        WeChatShareImageModel(WeChatImageToShare(uint8List: imageBytes),
            scene: scene),
      );

      if (result) {
        return true;
      } else {
        _showErrorSnackbar('分享失败');
        return false;
      }
    } catch (e) {
      print('分享到微信失败: $e');
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
