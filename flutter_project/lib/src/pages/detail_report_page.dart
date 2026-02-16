import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../cache/cache_manager.dart';
import '../models/user_data.dart';

class DetailReportPageController extends StatefulWidget {
  const DetailReportPageController({super.key});

  @override
  State<DetailReportPageController> createState() =>
      _DetailReportPageControllerState();
}

class _DetailReportPageControllerState
    extends State<DetailReportPageController> {
  int _totalDays = 0;
  int _streakPercent = 35;
  int _rankPercent = 82;
  String _year = '2026';

  final List<Map<String, dynamic>> _industries = [
    {'name': '互联网/电子通信', 'percent': 28},
    {'name': '金融/银行/保险', 'percent': 19},
    {'name': '教育/培训/科研', 'percent': 15},
    {'name': '房地产/建筑工程', 'percent': 12},
    {'name': '生产/制造/机械', 'percent': 10},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cacheManager = await CacheManager.getInstance();
      final jsonString = await cacheManager.getString(CacheKeys.userData);

      if (jsonString != null) {
        try {
          final userData = jsonDecode(jsonString);
          _totalDays = userData['days'] ?? 128;
        } catch (e) {
          _totalDays = 128;
        }
      } else {
        _totalDays = 128;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('加载数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4a3621);
    final backgroundLight = const Color(0xFFf9f8f3);
    final backgroundDark = const Color(0xFF1d1915);

    _year = DateTime.now().year.toString();

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: DetailGrainTexturePainter(
                  color: primaryColor.withValues(alpha: 0.03),
                ),
              ),
            ),
            Positioned(
              top: -100,
              right: -80,
              child: _buildDecorativeCircle(primaryColor, 200),
            ),
            Positioned(
              bottom: 150,
              left: -100,
              child: _buildDecorativeCircle(primaryColor, 250),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopNavigation(primaryColor),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildDaysCard(primaryColor, isDarkMode),
                          const SizedBox(height: 16),
                          _buildReasonCard(primaryColor, isDarkMode),
                          const SizedBox(height: 16),
                          _buildIndustriesCard(primaryColor, isDarkMode),
                          const SizedBox(height: 16),
                          _buildRankCard(primaryColor, isDarkMode),
                          const SizedBox(height: 24),
                          _buildFooterNote(primaryColor),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomAction(primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        shape: BoxShape.circle,
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
              '你的 $_year 忍耐报告',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildDaysCard(Color primaryColor, bool isDarkMode) {
    return _buildInfoCard(
      primaryColor: primaryColor,
      isDarkMode: isDarkMode,
      icon: Icons.calendar_today,
      iconSize: 16,
      title: '忍住没辞职',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$_totalDays',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : primaryColor,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 16),
                child: Text(
                  '天',
                  style: TextStyle(
                    color: primaryColor.withValues(alpha: 0.6),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressBar(primaryColor, _streakPercent / 100, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildReasonCard(Color primaryColor, bool isDarkMode) {
    return _buildInfoCard(
      primaryColor: primaryColor,
      isDarkMode: isDarkMode,
      icon: Icons.psychology,
      iconSize: 16,
      title: '最想辞职原因',
      child: Column(
        children: [
          Text(
            '工作内容 ${primaryColor.withValues(alpha: 0.3)} 情绪消耗',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.white : primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '"在这段沉默的时光里，你独自对抗了数不清的琐碎与疲惫。"',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryColor.withValues(alpha: 0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustriesCard(Color primaryColor, bool isDarkMode) {
    return _buildInfoCard(
      primaryColor: primaryColor,
      isDarkMode: isDarkMode,
      icon: Icons.leaderboard,
      iconSize: 16,
      title: '最想辞职行业 TOP5',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ..._industries.map((industry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          industry['name'] as String,
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.8)
                                : primaryColor.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${industry['percent']}%',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.5)
                              : primaryColor.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildProgressBar(primaryColor,
                      (industry['percent'] as int) / 30, isDarkMode,
                      barHeight: 4),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRankCard(Color primaryColor, bool isDarkMode) {
    return _buildInfoCard(
      primaryColor: primaryColor,
      isDarkMode: isDarkMode,
      icon: Icons.workspace_premium,
      iconSize: 16,
      title: '你击败了全国',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$_rankPercent%',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : primaryColor,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 16),
                child: Text(
                  '的忍者',
                  style: TextStyle(
                    color: primaryColor.withValues(alpha: 0.6),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              final opacity = (index + 1) * 0.25;
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color:
                      primaryColor.withValues(alpha: opacity.clamp(0.0, 1.0)),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required Color primaryColor,
    required bool isDarkMode,
    required IconData icon,
    required double iconSize,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: primaryColor.withValues(alpha: 0.4),
                size: iconSize,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: primaryColor.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(child: child),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color primaryColor, double percent, bool isDarkMode,
      {double barHeight = 6}) {
    return Container(
      width: double.infinity,
      height: barHeight,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(barHeight / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(barHeight / 2),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: percent.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(barHeight / 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterNote(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        '这一年，你辛苦了',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: primaryColor.withValues(alpha: 0.3),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildBottomAction(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SizedBox(
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
            elevation: 8,
            shadowColor: primaryColor.withValues(alpha: 0.4),
          ),
          onPressed: () {
            Get.toNamed('/report_share_card');
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.share,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                '生成报告分享卡',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailGrainTexturePainter extends CustomPainter {
  final Color color;

  DetailGrainTexturePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
