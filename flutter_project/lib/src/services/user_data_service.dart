import 'dart:async';
import '../cache/cache_manager.dart';
import '../models/user_data.dart';

class UserDataService {
  static UserDataService? _instance;
  late CacheManager _cacheManager;

  UserDataService._();

  static Future<UserDataService> getInstance() async {
    _instance ??= UserDataService._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    _cacheManager = await CacheManager.getInstance();
  }

  Future<UserData> getUserData() async {
    try {
      final jsonString = await _cacheManager.getString(CacheKeys.userData);
      if (jsonString != null) {
        return UserData.fromJsonString(jsonString);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
    return UserData();
  }

  Future<void> saveUserData(UserData data) async {
    data.lastUpdated = DateTime.now();
    final jsonString = data.toJsonString();
    await _cacheManager.setString(CacheKeys.userData, jsonString);
  }

  Future<int> getDays() async {
    final data = await getUserData();
    return 30;
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
}
