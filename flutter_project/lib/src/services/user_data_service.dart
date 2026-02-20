import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../cache/cache_manager.dart';
import '../models/user_data.dart';
import '../models/checkin_response.dart' as api;
import 'payment_service.dart';

class UserDataService {
  static UserDataService? _instance;
  late CacheManager _cacheManager;
  bool _initialized = false;

  UserDataService._();

  static Future<UserDataService> getInstance() async {
    _instance ??= UserDataService._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    if (_initialized) return;
    _cacheManager = await CacheManager.getInstance();
    _initialized = true;
  }

  Future<UserData> getUserData() async {
    try {
      final jsonString = await _cacheManager.getString(CacheKeys.userData);
      if (jsonString != null) {
        final data = UserData.fromJsonString(jsonString);
        if (data.isFirstTimeUser) {
          return _initializeFirstTimeUser(data);
        }
        return data;
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
    return _createNewUser();
  }

  UserData _createNewUser() {
    final data = UserData();
    return _initializeFirstTimeUser(data);
  }

  UserData _initializeFirstTimeUser(UserData data) {
    if (data.userId.isEmpty) {
      data.userId = _generateUserId();
    }
    if (data.industryResignationInfo.isEmpty) {
      data.industryResignationInfo = _generateDefaultIndustryResignationInfo();
    }
    if (data.appRankingPercentile == 100.0) {
      data.appRankingPercentile = _generateRandomRanking();
    }
    return data;
  }

  String _generateUserId() {
    final random = Random();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  List<IndustryResignationData> _generateDefaultIndustryResignationInfo() {
    final random = Random();
    return [
      IndustryResignationData(
        industryName: '产品经理',
        resignationPercentage: double.parse(
            (65.0 + random.nextDouble() * 20.0).toStringAsFixed(1)),
      ),
      IndustryResignationData(
        industryName: '设计师',
        resignationPercentage: double.parse(
            (60.0 + random.nextDouble() * 20.0).toStringAsFixed(1)),
      ),
      IndustryResignationData(
        industryName: '前端开发',
        resignationPercentage: double.parse(
            (55.0 + random.nextDouble() * 20.0).toStringAsFixed(1)),
      ),
      IndustryResignationData(
        industryName: '后端开发',
        resignationPercentage: double.parse(
            (50.0 + random.nextDouble() * 20.0).toStringAsFixed(1)),
      ),
      IndustryResignationData(
        industryName: '移动端开发',
        resignationPercentage: double.parse(
            (58.0 + random.nextDouble() * 20.0).toStringAsFixed(1)),
      ),
      IndustryResignationData(
        industryName: '运营',
        resignationPercentage: double.parse(
            (62.0 + random.nextDouble() * 20.0).toStringAsFixed(1)),
      ),
      IndustryResignationData(
        industryName: '市场',
        resignationPercentage: double.parse(
            (55.0 + random.nextDouble() * 20.0).toStringAsFixed(1)),
      ),
      IndustryResignationData(
        industryName: '人事',
        resignationPercentage: double.parse(
            (45.0 + random.nextDouble() * 20.0).toStringAsFixed(1)),
      ),
      IndustryResignationData(
        industryName: '财务',
        resignationPercentage: double.parse(
            (40.0 + random.nextDouble() * 20.0).toStringAsFixed(1)),
      ),
      IndustryResignationData(
        industryName: '其他',
        resignationPercentage: double.parse(
            (50.0 + random.nextDouble() * 20.0).toStringAsFixed(1)),
      ),
    ]..sort(
        (a, b) => b.resignationPercentage.compareTo(a.resignationPercentage));
  }

  double _generateRandomRanking() {
    final random = Random();
    final ranking = random.nextDouble() * 40.0 + 50.0;
    return double.parse(ranking.toStringAsFixed(1));
  }

  Future<void> saveUserData(UserData data) async {
    data.lastUpdated = DateTime.now();
    final jsonString = data.toJsonString();
    await _cacheManager.setString(CacheKeys.userData, jsonString);
  }

  Future<int> getDays() async {
    final data = await getUserData();
    return data.days;
  }

  Future<void> setDays(int days) async {
    final data = await getUserData();
    data.days = days;
    await saveUserData(data);
  }

  Future<String> getCity() async {
    final data = await getUserData();
    return data.city;
  }

  Future<void> setCity(String city) async {
    final data = await getUserData();
    data.city = city;
    await saveUserData(data);
  }

  Future<String> getIndustry() async {
    final data = await getUserData();
    return data.industry;
  }

  Future<void> setIndustry(String industry) async {
    final data = await getUserData();
    data.industry = industry;
    await saveUserData(data);
  }

  Future<List<String>> getCheckedInDates() async {
    final data = await getUserData();
    return data.checkedInDates;
  }

  Future<void> addCheckedInDate(String date) async {
    final data = await getUserData();
    final dateStr = _formatDateFromIso(date);
    if (!data.checkedInDates.contains(dateStr)) {
      data.checkedInDates.add(dateStr);
      await saveUserData(data);
    }
  }

  Future<bool> isCheckedInToday() async {
    final data = await getUserData();
    final today = _formatDate(DateTime.now());
    return data.checkedInDates.contains(today);
  }

  String _formatDateFromIso(String isoDateStr) {
    final date = DateTime.parse(isoDateStr);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<List<IndustryResignationData>> getIndustryResignationInfo() async {
    final data = await getUserData();
    return data.industryResignationInfo;
  }

  Future<void> updateIndustryResignationInfo(
      IndustryResignationData info) async {
    final data = await getUserData();
    final index = data.industryResignationInfo
        .indexWhere((e) => e.industryName == info.industryName);
    if (index >= 0) {
      data.industryResignationInfo[index] = info;
    } else {
      data.industryResignationInfo.add(info);
    }
    data.industryResignationInfo.sort(
        (a, b) => b.resignationPercentage.compareTo(a.resignationPercentage));
    await saveUserData(data);
  }

  Future<double> getAppRankingPercentile() async {
    final data = await getUserData();
    return data.appRankingPercentile;
  }

  Future<void> updateAppRankingPercentile(double percentile) async {
    final data = await getUserData();
    data.appRankingPercentile = percentile;
    await saveUserData(data);
  }

  Future<void> updateUserData({
    int? days,
    String? city,
    String? industry,
    Map<String, dynamic>? extraData,
  }) async {
    final data = await getUserData();
    if (days != null) data.days = days;
    if (city != null) data.city = city;
    if (industry != null) data.industry = industry;
    if (extraData != null) data.extraData = extraData;
    await saveUserData(data);
  }

  Future<void> clearUserData() async {
    await _cacheManager.remove(CacheKeys.userData);
  }

  Future<String> getUserId() async {
    final data = await getUserData();
    return data.userId;
  }

  Future<bool> isProUser() async {
    try {
      final paymentService = await PaymentService.getInstance();
      final isPro = paymentService.isPro;
      final data = await getUserData();
      if (data.isPro != isPro) {
        data.isPro = isPro;
        await saveUserData(data);
      }
      return isPro;
    } catch (e) {
      final data = await getUserData();
      return data.isPro;
    }
  }

  Future<void> setProStatus(bool value) async {
    final data = await getUserData();
    data.isPro = value;
    await saveUserData(data);
  }

  Future<bool> syncCheckin() async {
    try {
      final data = await getUserData();

      final response = await ApiClient.instance.checkin(
        userId: data.userId,
        city: data.city,
        industry: data.industry,
        dailyReasonData: data.dailyReasonData,
      );

      final checkinResponse = api.CheckinResponse.fromJson(response);

      data.userId = checkinResponse.userId;
      data.days = checkinResponse.days;
      data.city = checkinResponse.city;
      data.industry = checkinResponse.industry;
      data.lastUpdated = checkinResponse.lastUpdated;
      data.checkedInDates = checkinResponse.checkedInDates;
      data.appRankingPercentile = checkinResponse.appRankingPercentile;

      data.industryResignationInfo = checkinResponse.industryResignationInfo
          .map((apiItem) => IndustryResignationData(
                industryName: apiItem.industryName,
                resignationPercentage: apiItem.resignationPercentage,
              ))
          .toList();

      await saveUserData(data);
      return true;
    } catch (e) {
      debugPrint('Sync checkin failed: $e');
      return false;
    }
  }

  Future<void> saveDailyReasonData(DailyReasonData reasonData) async {
    final data = await getUserData();
    data.dailyReasonData = reasonData;
    await saveUserData(data);
  }

  Future<DailyReasonData?> getDailyReasonData() async {
    final data = await getUserData();
    return data.dailyReasonData;
  }
}
