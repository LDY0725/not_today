import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

class ImageSaver {
  static Future<bool> saveWidgetToGallery({
    required GlobalKey repaintBoundaryKey,
    required BuildContext context,
    String fileName = 'share_card',
  }) async {
    try {
      final RenderRepaintBoundary? repaintBoundary =
          repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (repaintBoundary == null) {
        _showErrorSnackbar('无法获取卡片渲染对象');
        return false;
      }

      await Future.delayed(const Duration(milliseconds: 100));

      final image = await repaintBoundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        _showErrorSnackbar('图片转换失败');
        return false;
      }

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      final permissionStatus = await Permission.photos.request();

      if (permissionStatus.isGranted || permissionStatus.isLimited) {
        final result = await ImageGallerySaver.saveImage(
          imageBytes,
          quality: 100,
          name: '${fileName}_${DateTime.now().millisecondsSinceEpoch}',
        );

        if (result['isSuccess'] == true) {
          _showSuccessSnackbar();
          return true;
        } else {
          _showErrorSnackbar('保存失败');
          return false;
        }
      } else if (permissionStatus.isDenied) {
        _showPermissionDeniedSnackbar();
        return false;
      } else if (permissionStatus.isPermanentlyDenied) {
        _showPermanentlyDeniedSnackbar();
        await Future.delayed(const Duration(seconds: 1));
        permission_handler.openAppSettings();
        return false;
      } else {
        _showErrorSnackbar('无法保存到相册');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('保存失败: $e');
      return false;
    }
  }

  static void _showSuccessSnackbar() {
    Get.snackbar(
      '保存成功',
      '卡片已保存到相册',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4a3621),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  static void _showErrorSnackbar(String message) {
    Get.snackbar(
      '保存失败',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  static void _showPermissionDeniedSnackbar() {
    Get.snackbar(
      '权限不足',
      '请在设置中开启相册权限',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  static void _showPermanentlyDeniedSnackbar() {
    Get.snackbar(
      '权限被拒绝',
      '请在设置中开启相册权限以保存图片',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
