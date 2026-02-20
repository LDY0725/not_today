import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IndexPageController extends StatelessWidget {
  const IndexPageController({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4a3621);
    final backgroundLight = const Color(0xFFf7f7f6);
    final backgroundDark = const Color(0xFF1d1915);

    final isDarkMode = false;

    final pages = [
      {
        'title': '首页',
        'subtitle': '咖啡杯交互',
        'icon': Icons.home,
        'route': '/home',
        'color': Colors.blue
      },
      {
        'title': '结果页',
        'subtitle': '忍耐天数统计',
        'icon': Icons.analytics,
        'route': '/result',
        'color': Colors.green
      },
      {
        'title': '分享卡片',
        'subtitle': '生成分享卡片',
        'icon': Icons.share,
        'route': '/share_card',
        'color': Colors.orange
      },
      {
        'title': '勋章',
        'subtitle': '我的忍耐勋章',
        'icon': Icons.workspace_premium,
        'route': '/medal',
        'color': Colors.amber
      },
      {
        'title': '报告页',
        'subtitle': '年度报告',
        'icon': Icons.description,
        'route': '/report',
        'color': Colors.purple
      },
      {
        'title': '详细报告',
        'subtitle': '深度分析报告',
        'icon': Icons.insights,
        'route': '/detail_report',
        'color': Colors.red
      },
      {
        'title': '支付页',
        'subtitle': '支付确认',
        'icon': Icons.payment,
        'route': '/payment',
        'color': Colors.teal
      },
      {
        'title': '报告分享卡',
        'subtitle': '分享卡片预览',
        'icon': Icons.image,
        'route': '/report_share_card',
        'color': Colors.indigo
      },
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text(
                '不干了',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '页面索引',
                style: TextStyle(
                  color: primaryColor.withValues(alpha: 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: pages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final page = pages[index];
                        return _buildNavButton(
                          context: context,
                          title: page['title'] as String,
                          subtitle: page['subtitle'] as String,
                          icon: page['icon'] as IconData,
                          route: page['route'] as String,
                          color: page['color'] as Color,
                          primaryColor: primaryColor,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Flutter Project',
                style: TextStyle(
                  color: primaryColor.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required Color color,
    required Color primaryColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (route == '/') {
            Get.offAllNamed(route);
          } else {
            Get.toNamed(route);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: primaryColor.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: primaryColor.withValues(alpha: 0.3),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
