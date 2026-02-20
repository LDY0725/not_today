import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/user_data_service.dart';
import '../services/payment_service.dart';
import '../models/user_data.dart';

class DetailReportPage extends StatefulWidget {
  const DetailReportPage({super.key});

  @override
  State<DetailReportPage> createState() => _DetailReportPageState();
}

class _DetailReportPageState extends State<DetailReportPage> {
  int _totalDays = 0;
  int _streakPercent = 35;
  double _rankPercent = 82;
  String _year = '2026';
  bool _isPro = false;

  List<IndustryResignationData> _industries = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      final userDataService = await UserDataService.getInstance();
      final paymentService = await PaymentService.getInstance();

      if (!mounted) return;

      final userData = await userDataService.getUserData();
      final isPro = await userDataService.isProUser();

      setState(() {
        _totalDays = userData.days;
        if (userData.industryResignationInfo.length > 5) {
          _industries = userData.industryResignationInfo.sublist(0, 5);
        } else {
          _industries = userData.industryResignationInfo;
        }
        _rankPercent = userData.appRankingPercentile;
        _streakPercent = _calculateStreakPercent(userData.days);
        _year = DateTime.now().year.toString();
        _isPro = isPro || userData.isPro;
      });
    } catch (e) {
      debugPrint('加载数据失败: $e');
    }
  }

  int _calculateStreakPercent(int days) {
    if (days <= 0) return 10;
    if (days <= 7) return 20;
    if (days <= 30) return 35;
    if (days <= 90) return 50;
    if (days <= 180) return 65;
    if (days <= 365) return 80;
    return 95;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = false;
    final primaryColor = const Color(0xFF4a3621);
    final backgroundLight = const Color(0xFFf9f8f3);
    final backgroundDark = const Color(0xFF1d1915);

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
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
                fontFamily: 'NotoSerifSC',
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
                  fontFamily: 'NotoSerifSC',
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
                    fontFamily: 'NotoSerifSC',
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
          Row(
            children: [
              Text(
                '工作内容',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoSerifSC',
                  height: 1.3,
                ),
              ),
              Text(
                '+',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  fontFamily: 'NotoSerifSC',
                ),
              ),
              Text(
                '情绪消耗',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  fontFamily: 'NotoSerifSC',
                ),
              ),
            ],
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
              letterSpacing: -0.5,
              fontFamily: 'NotoSerifSC',
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
            final displayPercent =
                (industry.resignationPercentage / 100).clamp(0.0, 1.0);
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
                          industry.industryName,
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.8)
                                : primaryColor.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'NotoSerifSC',
                          ),
                        ),
                      ),
                      Text(
                        '${industry.resignationPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.5)
                              : primaryColor.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'NotoSerifSC',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildProgressBar(primaryColor, displayPercent, isDarkMode,
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
                  fontFamily: 'NotoSerifSC',
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
                    fontFamily: 'NotoSerifSC',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
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
                  fontFamily: 'NotoSerifSC',
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
          fontFamily: 'NotoSerifSC',
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
            backgroundColor: _isPro ? primaryColor : const Color(0xFFec5b13),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            shadowColor: primaryColor.withValues(alpha: 0.4),
          ),
          onPressed: () {
            if (_isPro) {
              Get.toNamed('/report_share_card');
            } else {
              Get.toNamed('/payment');
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isPro ? Icons.share : Icons.lock,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                _isPro ? '生成报告分享卡' : '付费解锁完整报告',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  fontFamily: 'NotoSerifSC',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class DetailGrainTexturePainter extends CustomPainter {
//   final Color color;

//   DetailGrainTexturePainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;

//     final random = math.Random(42);
//     for (int i = 0; i < 200; i++) {
//       final x = random.nextDouble() * size.width;
//       final y = random.nextDouble() * size.height;
//       final radius = random.nextDouble() * 1.5;
//       canvas.drawCircle(
//         Offset(x, y),
//         radius,
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
