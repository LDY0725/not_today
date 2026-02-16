import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'base_page.dart';
import '../cache/cache_manager.dart';
import '../models/user_data.dart';

class ShareCardPageController extends StatefulWidget {
  const ShareCardPageController({super.key});

  @override
  State<ShareCardPageController> createState() =>
      _ShareCardPageControllerState();
}

class _ShareCardPageControllerState extends State<ShareCardPageController>
    with BasePageController {
  final GlobalKey _cardKey = GlobalKey();
  UserData _userData = UserData();
  bool _isSaving = false;

  @override
  String get pageTitle => '分享卡片预览';

  @override
  bool get showAppBar => false;

  @override
  void loadData() async {
    setLoading(true);
    try {
      final cacheManager = await CacheManager.getInstance();
      final jsonString = await cacheManager.getString(CacheKeys.userData);

      if (jsonString != null) {
        setState(() {
          _userData = UserData.fromJsonString(jsonString);
        });
      }
    } catch (e) {
      setError('加载数据失败: $e');
    }
    setLoading(false);
  }

  Future<void> _saveImage() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      Get.snackbar(
        '保存成功',
        '卡片已保存到相册',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4a3621),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        '保存失败',
        '请稍后重试',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4a3621);
    final backgroundLight = const Color(0xFFf7f7f6);
    final backgroundDark = const Color(0xFF1d1915);
    final cardWarm = const Color(0xFFFAF9F6);

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNavigation(primaryColor),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildCard(primaryColor, cardWarm, isDarkMode),
                    const SizedBox(height: 24),
                    _buildHelperText(primaryColor),
                    const SizedBox(height: 24),
                    _buildActionButtons(primaryColor, isDarkMode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation(Color primaryColor) {
    final backgroundDark = const Color(0xFF1d1915);
    return Container(
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark
                ? backgroundDark
                : Colors.white)
            .withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: primaryColor.withValues(alpha: 0.05),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: primaryColor,
                size: 22,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '分享卡片预览',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildCard(
    Color primaryColor,
    Color cardWarm,
    bool isDarkMode,
  ) {
    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        width: 320,
        height: 420,
        decoration: BoxDecoration(
          color: cardWarm,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 25,
              offset: const Offset(0, 20),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                size: Size.infinite,
                painter: GrainTexturePainter(
                  color: primaryColor.withValues(alpha: 0.03),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STILL HERE',
                        style: TextStyle(
                          color: primaryColor.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '今天，我还是没走',
                        style: TextStyle(
                          color: const Color(0xFF161413),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildStatSection(primaryColor),
                  const Spacer(),
                  _buildBadgeSection(primaryColor),
                  const Spacer(),
                  _buildFooter(primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSection(Color primaryColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: primaryColor.withValues(alpha: 0.1),
              ),
              bottom: BorderSide(
                color: primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Column(
            children: [
              Text(
                '累计忍住辞职',
                style: TextStyle(
                  color: primaryColor.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${_userData.days > 0 ? _userData.days : 128}',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 20),
                    child: Text(
                      '天',
                      style: TextStyle(
                        color: primaryColor.withValues(alpha: 0.8),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeSection(Color primaryColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium,
                color: primaryColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '🙃 明年再说型选手',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '"人人都在上班，但不是每个人都甘心。"',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryColor.withValues(alpha: 0.5),
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Color primaryColor) {
    final city = _userData.city.isNotEmpty ? _userData.city : '上海';
    final industry =
        _userData.industry.isNotEmpty ? _userData.industry : '产品经理';

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From App',
                    style: TextStyle(
                      color: primaryColor.withValues(alpha: 0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    '不干了',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$city · $industry',
                        style: TextStyle(
                          color: primaryColor.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.66,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHelperText(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline,
          color: primaryColor.withValues(alpha: 0.4),
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          '长按图片或点击下方按钮保存',
          style: TextStyle(
            color: primaryColor.withValues(alpha: 0.4),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color primaryColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: primaryColor.withValues(alpha: 0.3),
              ),
              onPressed: _isSaving ? null : _saveImage,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isSaving ? Icons.hourglass_empty : Icons.download,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isSaving ? '保存中...' : '保存图片',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              onPressed: () => Get.back(),
              child: const Text(
                '返回',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GrainTexturePainter extends CustomPainter {
  final Color color;

  GrainTexturePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final spacing = 16.0;
    final radius = 0.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          radius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
