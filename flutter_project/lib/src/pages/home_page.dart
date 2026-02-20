import 'package:flutter/material.dart';
import 'package:flutter_project/src/utils/quote_utils.dart';
import 'package:get/get.dart';
import 'base_page.dart';
import '../services/user_data_service.dart';
import '../utils/reason_utils.dart';
import '../models/user_data.dart';
import 'dart:async';

class HomePageController extends StatefulWidget {
  const HomePageController({super.key});

  @override
  State<HomePageController> createState() => _HomePageControllerState();
}

class _HomePageControllerState extends State<HomePageController>
    with BasePageController, SingleTickerProviderStateMixin {
  late AnimationController _coffeeController;
  late Animation<double> _steamAnimation;
  late Animation<double> _cupScaleAnimation;
  bool _showButton = false;
  bool _isPressed = false;
  bool _isSubmitting = false;
  int _tapCount = 0;
  String _selectedCity = '';
  String _selectedIndustry = '';
  List<DateTime> _tapTimestamps = [];
  List<Duration> _tapIntervals = [];
  DateTime? _sessionStartTime;
  late UserDataService _userDataService;
  String _homePageTitle = QuoteUtils.getRandomQuote(QuoteType.homePage);
  @override
  String get pageTitle => '';

  @override
  bool get showAppBar => false;

  @override
  void initState() {
    super.initState();
    _coffeeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _steamAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween:
            Tween(begin: 0.4, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_coffeeController);

    _cupScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_coffeeController);
  }

  @override
  void loadData() async {
    setLoading(true);
    _userDataService = await UserDataService.getInstance();
    final userData = await _userDataService.getUserData();

    setState(() {
      _selectedCity = userData.city;
      _selectedIndustry = userData.industry;
    });

    final now = DateTime.now();
    final lastUpdated = userData.lastUpdated;

    if (lastUpdated != null &&
        lastUpdated.year == now.year &&
        lastUpdated.month == now.month &&
        lastUpdated.day == now.day) {
      Get.offAllNamed('/result');
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));
    setLoading(false);
  }

  void _handleTap() {
    final now = DateTime.now();

    if (_sessionStartTime == null) {
      _sessionStartTime = now;
    }

    if (_tapTimestamps.isNotEmpty) {
      final lastTap = _tapTimestamps.last;
      final interval = now.difference(lastTap);
      _tapIntervals.add(interval);
    }

    _tapTimestamps.add(now);

    setState(() {
      _tapCount++;
    });

    if (_tapCount >= 3) {
      setState(() {
        _showButton = true;
      });
      _coffeeController.forward();
    } else {
      _coffeeController
        ..reset()
        ..forward();
    }
  }

  void _onCityChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedCity = value;
    });
    _userDataService.setCity(value);
  }

  void _onIndustryChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedIndustry = value;
    });
    _userDataService.setIndustry(value);
  }

  Future<DailyReasonData> _computeDailyReason(int currentStreakDays) async {
    final utils = ReasonScoreUtils();
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final existingData = await _userDataService.getDailyReasonData();
    final existingReasons = <DailyReasonItem>[];

    if (existingData != null &&
        existingData.date.year == today.year &&
        existingData.date.month == today.month &&
        existingData.date.day == today.day) {
      existingReasons.addAll(existingData.reasons);
    }

    int tapCount = _tapTimestamps.length;
    double avgInterval = 0;
    if (_tapIntervals.isNotEmpty) {
      avgInterval =
          _tapIntervals.fold<double>(0, (sum, d) => sum + d.inMilliseconds) /
              _tapIntervals.length;
    }
    double sessionDuration = 0;
    if (_sessionStartTime != null && _tapTimestamps.isNotEmpty) {
      sessionDuration = _tapTimestamps.last
          .difference(_sessionStartTime!)
          .inSeconds
          .toDouble();
    }

    TimeSlot slot;
    final hour = today.hour;
    final weekday = today.weekday;

    if (weekday == DateTime.sunday && hour >= 20) {
      slot = TimeSlot.sunNight;
    } else if (weekday >= DateTime.monday &&
        weekday <= DateTime.friday &&
        hour >= 9 &&
        hour < 18) {
      slot = TimeSlot.wkdayDay;
    } else if (weekday == DateTime.monday && hour >= 6 && hour < 12) {
      slot = TimeSlot.monMorning;
    } else if (weekday == DateTime.friday && hour >= 18) {
      slot = TimeSlot.friNight;
    } else {
      slot = TimeSlot.other;
    }

    final input = DailyInput(
      c: tapCount,
      delta: avgInterval,
      t: sessionDuration,
      slot: slot,
    );

    final scores = utils.computeFinalScores(input, currentStreakDays);

    final reasonNames = ['工作内容/强度', '情绪消耗', '未来不确定', '人际关系', '回报不匹配', '倦怠/无意义'];

    final newReasons = <DailyReasonItem>[];

    for (int i = 0; i < scores.length; i++) {
      final reasonName = reasonNames[i];
      final existingIndex =
          existingReasons.indexWhere((r) => r.reasonName == reasonName);
      double finalScore = scores[i];

      if (existingIndex >= 0) {
        final existing = existingReasons[existingIndex];
        finalScore = (existing.score + scores[i]) / 2;
        newReasons.add(DailyReasonItem(
          reasonName: reasonName,
          score: finalScore,
          tapCount: existing.tapCount + tapCount,
        ));
      } else {
        newReasons.add(DailyReasonItem(
          reasonName: reasonName,
          score: scores[i],
          tapCount: tapCount,
        ));
      }
    }

    newReasons.sort((a, b) => b.score.compareTo(a.score));

    return DailyReasonData(
      date: today,
      reasons: newReasons,
    );
  }

  @override
  void dispose() {
    _coffeeController.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    final isDarkMode = false;
    final primaryColor = const Color(0xFF4a3621);
    final backgroundLight = const Color(0xFFf7f7f6);
    final backgroundDark = const Color(0xFF1d1915);

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(primaryColor),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeroContent(primaryColor, isDarkMode),
                  const SizedBox(height: 32),
                  _buildCoffeeCupArea(primaryColor, isDarkMode),
                  const SizedBox(height: 32),
                  _buildTapHint(isDarkMode),
                ],
              ),
            ),
            _buildSelectionBar(primaryColor, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.coffee,
              color: primaryColor,
              size: 24,
            ),
          ),
          Expanded(
            child: Text(
              '不干了 / QUIT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildHeroContent(Color primaryColor, bool isDarkMode) {
    return Column(
      children: [
        Text(
          '今天辞职吗？',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.white : primaryColor,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
            fontFamily: 'NotoSerifSC',
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _homePageTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryColor.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              fontFamily: 'NotoSerifSC',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoffeeCupArea(Color primaryColor, bool isDarkMode) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _handleTap,
      child: SizedBox(
        height: 340,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Image.asset(
              _isPressed
                  ? 'assets/images/dark2.png'
                  : 'assets/images/dark1.png',
              width: 260,
              height: 260,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showButton ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_showButton,
                  child: SizedBox(
                    width: 260,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () async {
                        final userDataService =
                            await UserDataService.getInstance();

                        setState(() {
                          _isSubmitting = true;
                        });

                        final days = await userDataService.getDays();
                        final dailyReason = await _computeDailyReason(days);
                        await userDataService.saveDailyReasonData(dailyReason);

                        final success = await userDataService.syncCheckin();

                        setState(() {
                          _isSubmitting = false;
                        });

                        if (success) {
                          _tapTimestamps = [];
                          _tapIntervals = [];
                          _sessionStartTime = null;
                          _tapCount = 0;

                          Get.snackbar(
                            '打卡成功',
                            '恭喜你又坚持了一天！',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF07C160),
                            colorText: Colors.white,
                          );
                          Get.toNamed('/result');
                        } else {
                          Get.snackbar(
                            '打卡失败',
                            '请稍后重试',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: Text(
                        _isSubmitting ? '打卡中...' : '我不干了！',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapHint(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Text(
        '连点试试，别急着做决定',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDarkMode
              ? const Color(0xFF4a3621).withValues(alpha: 0.3)
              : const Color(0xFF4a3621).withValues(alpha: 0.3),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
          fontFamily: 'NotoSerifSC',
        ),
      ),
    );
  }

  Widget _buildSelectionBar(Color primaryColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdownSelector(
              primaryColor: primaryColor,
              hint: '你在哪个城市',
              value: _selectedCity.isEmpty ? null : _selectedCity,
              items: QuoteUtils.cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(
                    city,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _onCityChanged,
              isDarkMode: isDarkMode,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdownSelector(
              primaryColor: primaryColor,
              hint: '你做什么行业',
              value: _selectedIndustry.isEmpty ? null : _selectedIndustry,
              items: QuoteUtils.industries.map((industry) {
                return DropdownMenuItem(
                  value: industry,
                  child: Text(
                    industry,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: _onIndustryChanged,
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSelector({
    required Color primaryColor,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1d1915) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(
          hint,
          style: TextStyle(
            color: primaryColor.withValues(alpha: 0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        items: items,
        onChanged: onChanged,
        icon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(
            Icons.expand_more,
            color: primaryColor.withValues(alpha: 0.4),
            size: 20,
          ),
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
        dropdownColor: isDarkMode ? const Color(0xFF1d1915) : Colors.white,
        style: TextStyle(
          color: primaryColor.withValues(alpha: 0.8),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
