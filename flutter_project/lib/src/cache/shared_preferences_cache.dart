import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_service.dart';

class SharedPreferencesCache implements CacheService {
  static SharedPreferencesCache? _instance;
  late SharedPreferences _prefs;

  SharedPreferencesCache._();

  static Future<SharedPreferencesCache> getInstance() async {
    if (_instance == null) {
      _instance = SharedPreferencesCache._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<int> size() async {
    return _prefs.getKeys().length;
  }

  String _getTypeKey(String key, String type) => '${type}_$key';

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }

  Future<void> setComplex<T>(
    String key,
    T value,
    T Function(dynamic) fromJson,
    String Function(T) toJson,
  ) async {
    final jsonString = jsonEncode(value);
    await _prefs.setString(key, jsonString);
  }

  Future<T?> getComplex<T>(String key, T Function(dynamic) fromJson) async {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    final jsonMap = jsonDecode(jsonString);
    return fromJson(jsonMap);
  }
}
