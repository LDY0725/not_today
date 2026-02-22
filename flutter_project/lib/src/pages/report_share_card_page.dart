import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
import '../services/user_data_service.dart';
import '../models/user_data.dart';
import '../utils/image_saver.dart';
import '../utils/wechat_share_utils.dart';

class ReportShareCardPageController extends StatefulWidget {
  const ReportShareCardPageController({super.key});

  @override
  State<ReportShareCardPageController> createState() =>
      _ReportShareCardPageControllerState();
}

class _ReportShareCardPageControllerState
    extends State<ReportShareCardPageController> {
  int _totalDays = 0;
  double _rankPercent = 82;
  String _city = '';
  String _industry = '';
  String _reason = '无效会议 + 午休被占';
  bool _isSaving = false;
  bool _isSharingWechat = false;
  bool _isSharingTimeline = false;

  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userDataService = await UserDataService.getInstance();
      final userData = await userDataService.getUserData();

      if (mounted) {
        setState(() {
          _totalDays = userData.days > 0 ? userData.days : 0;
          _city = userData.city.isNotEmpty ? userData.city : '';
          _industry = userData.industry.isNotEmpty ? userData.industry : '产品经理';
          _rankPercent = userData.appRankingPercentile;
          if (userData.dailyReasonData?.reasons != null &&
              userData.dailyReasonData!.reasons!.isNotEmpty) {
            final sortedReasons =
                List<DailyReasonItem>.from(userData.dailyReasonData!.reasons!)
                  ..sort((a, b) => b.score.compareTo(a.score));
            final topTwo =
                sortedReasons.take(2).map((e) => e.reasonName).toList();
            _reason = topTwo.join(' + ');
          } else {
            _reason = '无效会议 + 午休被占';
          }
        });
      }
    } catch (e) {
      debugPrint('加载数据失败: $e');
    }
  }

  Future<void> _saveImage() async {
    setState(() {
      _isSaving = true;
    });

    final success = await ImageSaver.saveWidgetToGallery(
      repaintBoundaryKey: _cardKey,
      context: context,
      fileName: 'report_card',
    );

    setState(() {
      _isSaving = !success;
    });
  }

  Future<void> _shareToWechat(BuildContext context, WeChatScene scene) async {
    if (scene == WeChatScene.session) {
      setState(() {
        _isSharingWechat = true;
      });
    } else {
      setState(() {
        _isSharingTimeline = true;
      });
    }

    final imageBytes = await ImageSaver.transWidgetToImg(
      repaintBoundaryKey: _cardKey,
      context: context,
      fileName: 'share_card',
    );

    if (imageBytes == null) {
      if (scene == WeChatScene.session) {
        setState(() {
          _isSharingWechat = false;
        });
      } else {
        setState(() {
          _isSharingTimeline = false;
        });
      }
      return;
    }

    final success = await WechatShareUtils.shareImageToWechat(
        imageBytes: imageBytes, scene: scene);

    if (mounted) {
      if (scene == WeChatScene.session) {
        setState(() {
          _isSharingWechat = false;
        });
      } else {
        setState(() {
          _isSharingTimeline = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = false;
    final primaryColor = const Color(0xFF5d4037);
    final backgroundPaper = const Color(0xFFf7f3ed);
    final backgroundDark = const Color(0xFF2b2118);

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : const Color(0xFFfdfbf7),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNavigation(primaryColor, isDarkMode),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildShareCard(primaryColor, backgroundPaper, isDarkMode),
                    const SizedBox(height: 24),
                    _buildActionButtons(primaryColor, isDarkMode),
                    const SizedBox(height: 16),
                    _buildShareTips(primaryColor),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation(Color primaryColor, bool isDarkMode) {
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
              '报告分享卡片预览',
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

  Widget _buildShareCard(
    Color primaryColor,
    Color backgroundPaper,
    bool isDarkMode,
  ) {
    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundPaper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 20),
              spreadRadius: -10,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFe0dcd5),
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildGridBackground(),
                  const SizedBox(height: 32),
                  Container(
                    width: 48,
                    height: 2,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '今天，我还在。\n${_rankPercent.toStringAsFixed(0)}% 忍耐报告',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'NotoSerifSC',
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                children: [
                  _buildDataRow(
                    primaryColor: primaryColor,
                    label: '忍住没辞职',
                    value: '$_totalDays',
                    unit: '天',
                  ),
                  const SizedBox(height: 32),
                  _buildDataRow(
                    primaryColor: primaryColor,
                    label: '最想辞职原因',
                    value: _reason,
                    isText: true,
                  ),
                  const SizedBox(height: 32),
                  _buildDataRow(
                    primaryColor: primaryColor,
                    label: '击败了全国忍者',
                    value: '$_rankPercent',
                    unit: '%',
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: BoxDecoration(
                color: backgroundPaper.withValues(alpha: 0.5),
                border: Border(
                  top: BorderSide(
                    color: primaryColor.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_city · $_industry',
                          style: TextStyle(
                            color: primaryColor.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'NotoSerifSC',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '不干了 QUIT',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          fontFamily: 'NotoSerifSC',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: GridPaperPainter(),
      ),
    );
  }

  Widget _buildDataRow({
    required Color primaryColor,
    required String label,
    required String value,
    String unit = '',
    bool isText = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: primaryColor.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontFamily: 'NotoSerifSC',
          ),
        ),
        const SizedBox(height: 8),
        if (isText)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: primaryColor.withValues(alpha: 0.1)),
                bottom: BorderSide(color: primaryColor.withValues(alpha: 0.1)),
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'NotoSerifSC',
              ),
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  fontFamily: 'NotoSerifSC',
                ),
              ),
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 16),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'NotoSerifSC',
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButtons(Color primaryColor, bool isDarkMode) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: const Color(0xFFfdfbf7),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
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
              backgroundColor: const Color(0xFF07C160),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF07C160).withValues(alpha: 0.3),
            ),
            onPressed: _isSharingWechat
                ? null
                : () => _shareToWechat(context, WeChatScene.session),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  _isSharingWechat ? '分享中...' : '微信分享',
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
              backgroundColor: const Color(0xFF07C160),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF07C160).withValues(alpha: 0.3),
            ),
            onPressed: _isSharingTimeline
                ? null
                : () => _shareToWechat(context, WeChatScene.timeline),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  _isSharingTimeline ? '分享中...' : '朋友圈分享',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareTips(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '图片将保存至系统相册，快去朋友圈分享你的职业勋章吧',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: primaryColor.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class GridPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFe0dcd5)
      ..strokeWidth = 1;

    final spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
