import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math' as math;
import 'base_page.dart';
import '../cache/cache_manager.dart';
import '../models/user_data.dart';

class ResultPageController extends StatefulWidget {
  const ResultPageController({super.key});

  @override
  State<ResultPageController> createState() => _ResultPageControllerState();
}

class _ResultPageControllerState extends State<ResultPageController>
    with BasePageController, TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _numberAnimation;
  int _displayedDays = 0;
  UserData _userData = UserData();

  @override
  String get pageTitle => '今日记录';

  @override
  bool get showAppBar => false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _numberAnimation =
        Tween<double>(begin: 0, end: _userData.days.toDouble()).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

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

      _scaleController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _fadeController.forward();
        _animateNumber();
      });
    } catch (e) {
      setError('加载数据失败: $e');
    }
    setLoading(false);
  }

  void _animateNumber() {
    if (_userData.days <= 0) return;

    final totalDuration = 1500;
    final steps = 30;
    final stepDuration = totalDuration ~/ steps;
    final increment = _userData.days / steps;

    int currentStep = 0;
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: stepDuration));
      if (mounted) {
        setState(() {
          currentStep++;
          _displayedDays = (currentStep * increment).round();
          if (_displayedDays >= _userData.days) {
            _displayedDays = _userData.days;
          }
        });
      }
      return currentStep < steps && _displayedDays < _userData.days;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4a3621);
    final backgroundLight = const Color(0xFFf7f7f6);
    final backgroundDark = const Color(0xFF1d1915);

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      body: Stack(
        children: [
          _buildBackgroundPattern(isDarkMode),
          SafeArea(
            child: Column(
              children: [
                _buildTopNavigation(primaryColor),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMainContent(primaryColor, isDarkMode),
                        _buildActionButtons(primaryColor, isDarkMode),
                        _buildBranding(primaryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern(bool isDarkMode) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          size: Size.infinite,
          painter: DotGridPainter(
            color: const Color(0xFF4a3621).withOpacity(0.08),
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: primaryColor,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '今日记录',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Get.snackbar(
                '更多',
                '功能开发中...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: primaryColor,
                colorText: Colors.white,
              );
            },
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.more_horiz,
                color: primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(Color primaryColor, bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _fadeController,
          curve: Curves.easeOut,
        )),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              '今天，你还是没真的走',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 60),
            _buildDaysCounter(primaryColor, isDarkMode),
            const SizedBox(height: 40),
            _buildReflectiveText(primaryColor),
            const SizedBox(height: 24),
            _buildContextBadge(primaryColor),
            const SizedBox(height: 48),
            _buildDivider(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysCounter(Color primaryColor, bool isDarkMode) {
    return ScaleTransition(
      scale: _scaleController,
      child: Column(
        children: [
          Text(
            '你已经忍了',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryColor,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: _userData.days),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    value.toString(),
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 140,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -4,
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 28),
                child: Text(
                  '天',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReflectiveText(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        '你不是没勇气，\n是现在的你更清楚代价。',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: primaryColor.withOpacity(0.8),
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildContextBadge(Color primaryColor) {
    final city = _userData.city.isNotEmpty ? _userData.city : '未知';
    final industry = _userData.industry.isNotEmpty ? _userData.industry : '未知';

    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: primaryColor.withOpacity(0.5),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$city · $industry',
            style: TextStyle(
              color: primaryColor.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              primaryColor.withOpacity(0.2),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Color primaryColor, bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _fadeController,
          curve: Curves.easeOut,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildActionButton(
                primaryColor: primaryColor,
                label: '生成分享卡',
                icon: Icons.share,
                isPrimary: true,
                onPressed: () {
                  Get.toNamed('/share_card');
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                primaryColor: primaryColor,
                label: '查看我的勋章',
                icon: Icons.workspace_premium,
                isPrimary: false,
                onPressed: () {
                  Get.toNamed('/medal');
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                primaryColor: primaryColor,
                label: '查看我的忍耐报告',
                icon: Icons.description,
                isPrimary: false,
                onPressed: () {
                  Get.toNamed('/report');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required Color primaryColor,
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryColor : Colors.transparent,
          foregroundColor: isPrimary ? Colors.white : primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: isPrimary
              ? null
              : BorderSide(
                  color: primaryColor.withOpacity(0.2),
                  width: 2,
                ),
          elevation: isPrimary ? 4 : 0,
          shadowColor:
              isPrimary ? primaryColor.withOpacity(0.3) : Colors.transparent,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranding(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Opacity(
        opacity: 0.2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: 45 * math.pi / 180,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '不干了',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DotGridPainter extends CustomPainter {
  final Color color;

  DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final spacing = 24.0;
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
