import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static PaymentService? _instance;
  static const String _isProKey = 'is_pro_user';
  static const String _productId = 'nottoday.endurance.report';

  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isAvailable = false;
  bool _isPro = false;
  bool _isLoading = true;

  PaymentService._();

  static Future<PaymentService> getInstance() async {
    _instance ??= PaymentService._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    _isLoading = true;

    if (Platform.isIOS) {
      final InAppPurchase inAppPurchase = InAppPurchase.instance;
      _subscription = inAppPurchase.purchaseStream.listen(
        _listenToPurchaseUpdated,
        onDone: () => _subscription.cancel(),
        onError: (error) {
          debugPrint('Purchase stream error: $error');
        },
      );

      _isAvailable = await inAppPurchase.isAvailable();
      if (_isAvailable) {
        await _loadProduct();
      }
    }

    await _checkPaymentStatus();
    _isLoading = false;
  }

  Future<void> _loadProduct() async {
    if (!_isAvailable) return;

    final InAppPurchase inAppPurchase = InAppPurchase.instance;
    final productIds = <String>{_productId};

    await inAppPurchase.queryProductDetails(productIds);
  }

  bool get isAvailable => _isAvailable;

  bool get isPro => _isPro;

  bool get isLoading => _isLoading;

  Future<bool> _checkPaymentStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPro = prefs.getBool(_isProKey) ?? false;
      return _isPro;
    } catch (e) {
      debugPrint('Error checking payment status: $e');
      _isPro = false;
      return false;
    }
  }

  Future<void> _setProStatus(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isProKey, value);
      _isPro = value;
    } catch (e) {
      debugPrint('Error setting pro status: $e');
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        _verifyPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${purchaseDetails.error?.message}');
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        debugPrint('Purchase canceled');
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == _productId) {
      await _setProStatus(true);
    }

    if (purchaseDetails.pendingCompletePurchase) {
      final InAppPurchase inAppPurchase = InAppPurchase.instance;
      await inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  Future<bool> purchase() async {
    if (!_isAvailable) {
      debugPrint('In-app purchase not available');
      return false;
    }

    final InAppPurchase inAppPurchase = InAppPurchase.instance;
    final productIds = <String>{_productId};

    final response = await inAppPurchase.queryProductDetails(productIds);

    if (response.error != null) {
      debugPrint('Product query error: ${response.error?.message}');
      return false;
    }

    if (response.productDetails.isEmpty) {
      debugPrint('Product not found');
      return false;
    }

    final productDetails = response.productDetails.first;

    final purchaseParam = PurchaseParam(productDetails: productDetails);

    try {
      await inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    final InAppPurchase inAppPurchase = InAppPurchase.instance;
    try {
      await inAppPurchase.restorePurchases(applicationUserName: null);
    } catch (e) {
      debugPrint('Restore purchases error: $e');
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
