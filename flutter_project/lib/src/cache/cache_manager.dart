import 'cache_service.dart';
import 'shared_preferences_cache.dart';
import 'hive_cache.dart';

enum CacheType { simple, complex }

class CacheManager {
  static CacheManager? _instance;
  late SharedPreferencesCache _spCache;
  late HiveCache _hiveCache;
  CacheType _defaultType = CacheType.simple;

  CacheManager._();

  static Future<CacheManager> getInstance() async {
    _instance ??= CacheManager._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    _spCache = await SharedPreferencesCache.getInstance();
    _hiveCache = HiveCache.getInstance();
  }

  void setDefaultCacheType(CacheType type) {
    _defaultType = type;
  }

  Future<CacheService> _getCacheService(CacheType? type) async {
    final cacheType = type ?? _defaultType;
    switch (cacheType) {
      case CacheType.simple:
        return _spCache;
      case CacheType.complex:
        return _hiveCache;
    }
  }

  Future<bool> containsKey(String key, {CacheType? type}) async {
    final cache = await _getCacheService(type);
    return await cache.containsKey(key);
  }

  Future<void> remove(String key, {CacheType? type}) async {
    final cache = await _getCacheService(type);
    await cache.remove(key);
  }

  Future<void> clear({CacheType? type}) async {
    final cache = await _getCacheService(type);
    await cache.clear();
  }

  Future<int> size({CacheType? type}) async {
    final cache = await _getCacheService(type);
    return await cache.size();
  }

  Future<void> setString(String key, String value, {CacheType? type}) async {
    final cacheType = type ?? _defaultType;
    switch (cacheType) {
      case CacheType.simple:
        await _spCache.setString(key, value);
        break;
      case CacheType.complex:
        await _hiveCache.put(key, value);
        break;
    }
  }

  Future<String?> getString(String key, {CacheType? type}) async {
    final cacheType = type ?? _defaultType;
    switch (cacheType) {
      case CacheType.simple:
        return await _spCache.getString(key);
      case CacheType.complex:
        return await _hiveCache.get<String>(key);
    }
  }

  Future<void> setInt(String key, int value, {CacheType? type}) async {
    final cacheType = type ?? _defaultType;
    switch (cacheType) {
      case CacheType.simple:
        await _spCache.setInt(key, value);
        break;
      case CacheType.complex:
        await _hiveCache.put(key, value);
        break;
    }
  }

  Future<int?> getInt(String key, {CacheType? type}) async {
    final cacheType = type ?? _defaultType;
    switch (cacheType) {
      case CacheType.simple:
        return await _spCache.getInt(key);
      case CacheType.complex:
        return await _hiveCache.get<int>(key);
    }
  }

  Future<void> setDouble(String key, double value, {CacheType? type}) async {
    final cacheType = type ?? _defaultType;
    switch (cacheType) {
      case CacheType.simple:
        await _spCache.setDouble(key, value);
        break;
      case CacheType.complex:
        await _hiveCache.put(key, value);
        break;
    }
  }

  Future<double?> getDouble(String key, {CacheType? type}) async {
    final cacheType = type ?? _defaultType;
    switch (cacheType) {
      case CacheType.simple:
        return await _spCache.getDouble(key);
      case CacheType.complex:
        return await _hiveCache.get<double>(key);
    }
  }

  Future<void> setBool(String key, bool value, {CacheType? type}) async {
    final cacheType = type ?? _defaultType;
    switch (cacheType) {
      case CacheType.simple:
        await _spCache.setBool(key, value);
        break;
      case CacheType.complex:
        await _hiveCache.put(key, value);
        break;
    }
  }

  Future<bool?> getBool(String key, {CacheType? type}) async {
    final cacheType = type ?? _defaultType;
    switch (cacheType) {
      case CacheType.simple:
        return await _spCache.getBool(key);
      case CacheType.complex:
        return await _hiveCache.get<bool>(key);
    }
  }

  Future<void> setStringList(
    String key,
    List<String> value, {
    CacheType? type,
  }) async {
    final cacheType = type ?? _defaultType;
    switch (cacheType) {
      case CacheType.simple:
        await _spCache.setStringList(key, value);
        break;
      case CacheType.complex:
        await _hiveCache.put(key, value);
        break;
    }
  }

  Future<List<String>?> getStringList(String key, {CacheType? type}) async {
    final cacheType = type ?? _defaultType;
    switch (cacheType) {
      case CacheType.simple:
        return await _spCache.getStringList(key);
      case CacheType.complex:
        return await _hiveCache.get<List<String>>(key);
    }
  }

  Future<void> setComplex<T>(String key, T value, {String? boxName}) async {
    await _hiveCache.put(key, value, boxName: boxName);
  }

  Future<T?> getComplex<T>(String key, {String? boxName}) async {
    return await _hiveCache.get<T>(key, boxName: boxName);
  }

  Future<void> openHiveBox(String boxName) async {
    await _hiveCache.openBox(boxName);
  }

  Future<void> closeHiveBox(String boxName) async {
    await _hiveCache.closeBox(boxName);
  }

  Future<void> deleteHiveBoxFromDisk(String boxName) async {
    await _hiveCache.deleteFromDisk(boxName);
  }

  SharedPreferencesCache get sharedPreferencesCache => _spCache;
  HiveCache get hiveCache => _hiveCache;
}
