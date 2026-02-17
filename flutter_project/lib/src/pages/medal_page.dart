import 'package:flutter/material.dart';
import 'package:flutter_project/src/utils/quote_utils.dart';
import 'package:get/get.dart';
import 'base_page.dart';
import '../models/medal.dart';
import '../services/user_data_service.dart';

class MedalPageController extends StatefulWidget {
  const MedalPageController({super.key});

  @override
  State<MedalPageController> createState() => _MedalPageControllerState();
}

class _MedalPageControllerState extends State<MedalPageController>
    with BasePageController {
  List<Medal> _medals = [];
  final String _quote = QuoteUtils.getRandomQuote(QuoteType.modal);
  @override
  String get pageTitle => '我的忍耐勋章';

  @override
  bool get showAppBar => false;

  @override
  void loadData() async {
    setLoading(true);
    try {
      final medalService = MedalService.getInstance();
      final userDataService = await UserDataService.getInstance();
      final userData = await userDataService.getUserData();
      final currentStreak = userData.days > 0 ? userData.days : 0;
      setState(() {
        _medals = medalService.getAllMedals(currentStreak);
      });
    } catch (e) {
      setError('加载勋章数据失败: $e');
    }
    setLoading(false);
  }

  @override
  Widget buildContent(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4a3621);
    final backgroundLight = const Color(0xFFfdfbf7);
    final backgroundDark = const Color(0xFF1d1915);
    final warmGray = const Color(0xFFa89c91);

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopNavigation(primaryColor),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(primaryColor),
                    const SizedBox(height: 24),
                    _buildMedalList(primaryColor, warmGray, isDarkMode),
                    const SizedBox(height: 48),
                    _buildFooter(primaryColor),
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
          Expanded(child: Container()),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '我的忍耐勋章',
          style: TextStyle(
            color: primaryColor,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
            fontFamily: 'NotoSerifSC',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _quote,
          style: TextStyle(
            color: primaryColor.withValues(alpha: 0.7),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.3,
            fontFamily: 'NotoSerifSC',
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMedalList(
    Color primaryColor,
    Color warmGray,
    bool isDarkMode,
  ) {
    final unlockedMedals = _medals.where((m) => m.isUnlocked).toList();
    final lockedMedals = _medals.where((m) => !m.isUnlocked).toList();

    final allMedals = [...unlockedMedals, ...lockedMedals];

    return Column(
      children: allMedals.map((medal) {
        final index = allMedals.indexOf(medal);
        return Column(
          children: [
            _buildMedalCard(medal, primaryColor, warmGray, isDarkMode),
            if (index < allMedals.length - 1) const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMedalCard(
    Medal medal,
    Color primaryColor,
    Color warmGray,
    bool isDarkMode,
  ) {
    final isLocked = !medal.isUnlocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isLocked
            ? (isDarkMode
                ? primaryColor.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.5))
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? warmGray.withValues(alpha: 0.2)
              : primaryColor.withValues(alpha: 0.1),
        ),
        boxShadow: isLocked
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isLocked) {
            Get.snackbar(
              '未解锁',
              '需要连续签到 ${medal.requiredDays} 天才能解锁',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: primaryColor,
              colorText: Colors.white,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    getIconData(medal.iconName),
                    color: primaryColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (medal.isUnlocked) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '已解锁',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            fontFamily: 'NotoSerifSC',
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      medal.name,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        fontFamily: 'NotoSerifSC',
                      ),
                    ),
                    if (medal.isUnlocked) ...[
                      const SizedBox(height: 4),
                      Text(
                        medal.description,
                        style: TextStyle(
                          color: primaryColor.withValues(alpha: 0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'NotoSerifSC',
                          height: 1.4,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text(
                        '解锁条件：连续签到 ${medal.requiredDays} 天',
                        style: TextStyle(
                          color: primaryColor.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          fontFamily: 'NotoSerifSC',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(Color primaryColor) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 1,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(height: 32),
        Icon(
          Icons.local_florist,
          color: primaryColor.withValues(alpha: 0.2),
          size: 40,
        ),
      ],
    );
  }
}
