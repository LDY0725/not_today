import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'src/pages/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '不干了',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF4a3621),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF4a3621),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const IndexPageController(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomePageController(),
        ),
        GetPage(
          name: '/result',
          page: () => const ResultPageController(),
        ),
        GetPage(
          name: '/share_card',
          page: () => const ShareCardPageController(),
        ),
        GetPage(
          name: '/medal',
          page: () => const MedalPageController(),
        ),
        GetPage(
          name: '/report',
          page: () => const ReportPageController(),
        ),
        GetPage(
          name: '/detail_report',
          page: () => const DetailReportPage(),
        ),
        GetPage(
          name: '/payment',
          page: () => const PaymentPageController(),
        ),
        GetPage(
          name: '/report_share_card',
          page: () => const ReportShareCardPageController(),
        ),
      ],
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => Scaffold(
          appBar: AppBar(title: const Text('页面未找到')),
          body: Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('页面未找到'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed('/'),
                  child: const Text('返回首页'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
