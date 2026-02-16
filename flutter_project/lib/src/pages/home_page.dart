import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'base_page.dart';
import '../services/user_data_service.dart';
import 'dart:async';
import 'dart:math' as math;

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
  int _tapCount = 0;

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
    await Future.delayed(const Duration(milliseconds: 500));
    setLoading(false);
  }

  void _handleTap() {
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

  @override
  void dispose() {
    _coffeeController.dispose();
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
              color: primaryColor.withOpacity(0.1),
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
                letterSpacing: 4,
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
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            '有时候想离开，只是想确认自己还有选择。',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryColor.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoffeeCupArea(Color primaryColor, bool isDarkMode) {
    return GestureDetector(
      onTap: _handleTap,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _coffeeController,
            builder: (context, child) {
              return Transform.scale(
                scale: _cupScaleAnimation.value,
                child: child,
              );
            },
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _steamAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _steamAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, -_steamAnimation.value * 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform(
                              transform: Matrix4.identity()
                                ..scale(-1.0, 1.0, 1.0),
                              child: Icon(
                                Icons.air,
                                color: primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.air,
                              color: primaryColor,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _coffeeController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_coffeeController.value * 0.125),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(isDarkMode ? 0.1 : 0.05),
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(140, 140),
                        painter: CoffeeCupPainter(primaryColor: primaryColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showButton) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
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
                  final userDataService = await UserDataService.getInstance();
                  await userDataService.updateUserData(
                    days: 128,
                    city: '上海',
                    industry: '产品经理',
                  );
                  Get.toNamed('/result');
                },
                child: const Text(
                  '我不干了！',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
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
              ? const Color(0xFF4a3621).withOpacity(0.3)
              : const Color(0xFF4a3621).withOpacity(0.3),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
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
            child: _buildSelector(
              primaryColor: primaryColor,
              label: '你在哪个城市',
              icon: Icons.expand_more,
              isDarkMode: isDarkMode,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSelector(
              primaryColor: primaryColor,
              label: '你做什么行业',
              icon: Icons.expand_more,
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector({
    required Color primaryColor,
    required String label,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1d1915) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Get.snackbar(
            '提示',
            '选择功能开发中...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: primaryColor,
            colorText: Colors.white,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                icon,
                color: primaryColor.withOpacity(0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoffeeCupPainter extends CustomPainter {
  final Color primaryColor;

  CoffeeCupPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    final cupTopLeft = Offset(size.width * 0.25, size.height * 0.31);
    final cupTopRight = Offset(size.width * 0.69, size.height * 0.31);
    final cupBottomRight = Offset(size.width * 0.69, size.height * 0.56);
    final cupBottomLeft = Offset(size.width * 0.31, size.height * 0.56);

    path.moveTo(cupTopLeft.dx, cupTopLeft.dy);
    path.lineTo(cupBottomLeft.dx, cupBottomLeft.dy);
    path.quadraticBezierTo(
      cupBottomLeft.dx - 5,
      cupBottomLeft.dy + 20,
      cupBottomLeft.dx + 10,
      cupBottomLeft.dy + 35,
    );
    path.lineTo(cupBottomRight.dx - 10, cupBottomRight.dy + 35);
    path.quadraticBezierTo(
      cupBottomRight.dx + 5,
      cupBottomRight.dy + 20,
      cupBottomRight.dx,
      cupBottomRight.dy,
    );
    path.lineTo(cupTopRight.dx, cupTopRight.dy);

    path.moveTo(cupTopLeft.dx, cupTopLeft.dy);
    path.lineTo(cupTopRight.dx, cupTopRight.dy);
    path.moveTo(cupTopLeft.dx + 5, cupTopLeft.dy - 10);
    path.lineTo(cupTopLeft.dx + 5, cupTopLeft.dy - 20);
    path.moveTo(size.width * 0.44, cupTopLeft.dy - 10);
    path.lineTo(size.width * 0.44, cupTopLeft.dy - 20);
    path.moveTo(size.width * 0.69 - 5, cupTopLeft.dy - 10);
    path.lineTo(size.width * 0.69 - 5, cupTopLeft.dy - 20);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
