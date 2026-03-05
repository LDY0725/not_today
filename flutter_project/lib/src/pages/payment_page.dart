import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/payment_service.dart';
import '../services/user_data_service.dart';

class PaymentPageController extends StatefulWidget {
  const PaymentPageController({super.key});

  @override
  State<PaymentPageController> createState() => _PaymentPageControllerState();
}

class _PaymentPageControllerState extends State<PaymentPageController> {
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPayment();
  }

  Future<void> _initPayment() async {
    await PaymentService.getInstance();
    setState(() {});
  }

  Future<void> _handlePayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final paymentService = await PaymentService.getInstance();
      final success = await paymentService.purchase();

      if (success) {
        await _checkPaymentResult();
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage = '发起支付失败，请稍后重试';
        });
      }
    } catch (e) {
      print(e);
      print("----");
      setState(() {
        _isProcessing = false;
        _errorMessage = '支付错误: $e';
      });
    }
  }

  Future<void> _checkPaymentResult() async {
    await Future.delayed(const Duration(seconds: 2));

    final userDataService = await UserDataService.getInstance();
    final isPro = await userDataService.isProUser();

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (isPro) {
        Get.closeCurrentSnackbar();
        Get.snackbar(
          '支付成功',
          '感谢您的支持！',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF07C160),
          colorText: Colors.white,
        );

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Get.offAllNamed('/detail_report');
        }
      } else {
        setState(() {
          _errorMessage = '支付未完成，请重试';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFec5b13);
    const backgroundLight = Color(0xFFf8f6f6);

    final isDarkMode = false;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : backgroundLight,
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
                    _buildProductCard(primaryColor, isDarkMode),
                    const SizedBox(height: 32),
                    _buildPriceSection(primaryColor, isDarkMode),
                    const SizedBox(height: 32),
                    _buildPaymentMethods(primaryColor, isDarkMode),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorMessage(),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomAction(primaryColor, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation(Color primaryColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: (isDarkMode ? const Color(0xFF121212) : Colors.white)
            .withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_left,
                  color: isDarkMode ? Colors.white : primaryColor,
                  size: 24,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '解锁完整报告',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : const Color(0xFF1e293b),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Color primaryColor, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1e293b).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '完整忍耐报告',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF1e293b),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '解锁深度分析与建议\n查看完整行业报告',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.6)
                        : const Color(0xFF64748b),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.analytics,
              color: primaryColor,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(Color primaryColor, bool isDarkMode) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '¥',
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.6)
                    : const Color(0xFF64748b),
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Text(
              '2.00',
              style: TextStyle(
                color: Color(0xFF1e293b),
                fontSize: 56,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '一次性购买，永久使用',
          style: TextStyle(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.5)
                : const Color(0xFF64748b),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(Color primaryColor, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            '选择支付方式',
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.6)
                  : const Color(0xFF64748b),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
        ),
        _buildPaymentOption(
          primaryColor: primaryColor,
          isDarkMode: isDarkMode,
          name: 'Apple Pay',
          description: '安全、快捷支付',
          icon: Icons.phone_iphone,
          iconColor: Colors.black,
          bgColor: Colors.black,
          isSelected: true,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required Color primaryColor,
    required bool isDarkMode,
    required String name,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF1e293b).withValues(alpha: 0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: isSelected ? 0.1 : 0),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF1e293b),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.5)
                          : const Color(0xFF64748b),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : isDarkMode
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.2),
                  width: 2,
                ),
                color: isSelected ? primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(Color primaryColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          SizedBox(
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
                elevation: 4,
                shadowColor: primaryColor.withValues(alpha: 0.3),
              ),
              onPressed: _isProcessing ? null : _handlePayment,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isProcessing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  else
                    const Icon(Icons.lock, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isProcessing ? '支付中...' : '立即支付 ¥2.00',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user,
                color: primaryColor.withValues(alpha: 0.5),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '一次性购买｜不订阅，不自动扣费',
                style: TextStyle(
                  color: primaryColor.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
