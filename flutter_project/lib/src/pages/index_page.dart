import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IndexPageController extends StatelessWidget {
  const IndexPageController({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4a3621);
    final backgroundLight = const Color(0xFFf7f7f6);
    final backgroundDark = const Color(0xFF1d1915);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      {
        'title': '首页',
        'route': '/',
      },
      {
        'title': '结果页',
        'route': '/result',
      },
      {
        'title': '分享卡片',
        'route': '/share_card',
      },
      {
        'title': '勋章',
        'route': '/medal',
      },
      {
        'title': '报告页',
        'route': '/report',
      },
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                '页面索引',
                style: TextStyle(
                  color: primaryColor.withOpacity(0.6),
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
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final page = pages[index];
                        return _buildNavButton(
                          context: context,
                          title: page['title'] as String,
                          route: page['route'] as String,
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
                  color: primaryColor.withOpacity(0.4),
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
    required String route,
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
