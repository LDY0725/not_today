import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'base_page.dart';
import '../cache/cache_manager.dart';
import '../models/user_data.dart';

class ReportPageController extends StatefulWidget {
  const ReportPageController({super.key});

  @override
  State<ReportPageController> createState() => _ReportPageControllerState();
}

class _ReportPageControllerState extends State<ReportPageController>
    with BasePageController {
  int _totalDays = 0;
  int _currentStreak = 0;
  double _rankPercentile = 0;
  String _year = '2026';

  @override
  String get pageTitle => '忍耐报告';

  @override
  bool get showAppBar => false;

  @override
  void loadData() async {
    setLoading(true);
    try {
      final cacheManager = await CacheManager.getInstance();
      final jsonString = await cacheManager.getString(CacheKeys.userData);
      print(jsonString);

      if (jsonString != null) {
        try {
          final userData = jsonDecode(jsonString);
          _totalDays = userData['days'] ?? 285;
          _currentStreak = userData['days'] ?? _currentStreak;
          _rankPercentile = userData['appRankingPercentile'] ?? _rankPercentile;
          print("11_rankPercentile");
          print(_rankPercentile);
        } catch (e) {
          print(e);
          _totalDays = 0;
          _currentStreak = 0;
          _rankPercentile = 0;
        }
      } else {
        _totalDays = 0;
        _currentStreak = 0;
        _rankPercentile = 0;
      }

      setState(() {});
    } catch (e) {
      setError('加载数据失败: $e');
    }
    setLoading(false);
  }

  @override
  Widget buildContent(BuildContext context) {
    final isDarkMode = false;
    final primaryColor = const Color(0xFF4a3621);
    final backgroundLight = const Color(0xFFfdfbf7);
    final backgroundDark = const Color(0xFF1d1915);

    _year = DateTime.now().year.toString();

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopNavigation(primaryColor),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(primaryColor, isDarkMode),
                    _buildReportCard(primaryColor, isDarkMode),
                    _buildBottomDecoration(primaryColor),
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
              '忍耐报告',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '你的 $_year\n忍耐报告已生成',
            style: TextStyle(
              color: isDarkMode ? Colors.white : primaryColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
              fontFamily: 'NotoSerifSC',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '这些数据，只属于真的忍过的人',
            style: TextStyle(
              color: primaryColor.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
              fontFamily: 'NotoSerifSC',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Color primaryColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF18181b) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
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
                  Icons.history_edu,
                  color: primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '你的 $_year 忍耐报告',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSerifSC',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDaysSection(primaryColor, isDarkMode),
            const SizedBox(height: 20),
            _buildRankingSection(primaryColor, isDarkMode),
            const SizedBox(height: 20),
            _buildShareButton(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysSection(Color primaryColor, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: primaryColor,
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '这一年，你忍住没辞职',
            style: TextStyle(
              color: primaryColor.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'NotoSerifSC',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$_totalDays',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : primaryColor,
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  fontFamily: 'NotoSerifSC',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6, top: 16),
                child: Text(
                  '天',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSerifSC',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingSection(Color primaryColor, bool isDarkMode) {
    String rankPercentile = _rankPercentile.toStringAsFixed(2);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '全国"忍者"排名',
              style: TextStyle(
                color: primaryColor.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'NotoSerifSC',
              ),
            ),
            Text(
              '击败了 $rankPercentile% 的人',
              style: TextStyle(
                color: isDarkMode ? Colors.white : primaryColor,
                fontSize: 12,
                fontFamily: 'NotoSerifSC',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _rankPercentile / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () {
          Get.toNamed('/detail_report');
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.share,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              '查看 / 生成分享卡',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'NotoSerifSC',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomDecoration(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48, bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.coffee,
              color: primaryColor.withValues(alpha: 0.3),
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              '不干了 - 重新定义职场情绪',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor.withValues(alpha: 0.3),
                fontFamily: 'NotoSerifSC',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
