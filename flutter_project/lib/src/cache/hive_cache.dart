import 'dart:async';
import 'package:hive/hive.dart';
import 'cache_service.dart';

class HiveCache implements CacheService {
  static HiveCache? _instance;
  final Map<String, Box> _boxes = {};
  static const String _defaultBoxName = 'default';

  HiveCache._();

  static HiveCache getInstance() {
    _instance ??= HiveCache._();
    return _instance!;
  }

  Future<Box> _getBox([String? boxName]) async {
    final name = boxName ?? _defaultBoxName;
    if (!_boxes.containsKey(name)) {
      await openBox(name);
    }
    return _boxes[name]!;
  }

  @override
  Future<void> openBox(String boxName) async {
    if (!_boxes.containsKey(boxName)) {
      final box = await Hive.openBox(boxName);
      _boxes[boxName] = box;
    }
  }

  @override
  Future<void> closeBox(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      await _boxes[boxName]!.close();
      _boxes.remove(boxName);
    }
  }

  @override
  Future<bool> containsKey(String key, {String? boxName}) async {
    final box = await _getBox(boxName);
    return box.containsKey(key);
  }

  @override
  Future<void> remove(String key, {String? boxName}) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clear({String? boxName}) async {
    final box = await _getBox(boxName);
    await box.clear();
  }

  @override
  Future<int> size({String? boxName}) async {
    final box = await _getBox(boxName);
    return box.length;
  }

  Future<void> put<T>(String key, T value, {String? boxName}) async {
    final box = _boxes[boxName ?? 'default'];
    if (box != null) {
      await box.put(key, value);
    }
  }

  Future<T?> get<T>(String key, {String? boxName}) async {
    final box = _boxes[boxName ?? 'default'];
    if (box == null) return null;
    return box.get(key) as T?;
  }

  Future<void> putAll(Map<dynamic, dynamic> entries, {String? boxName}) async {
    final box = _boxes[boxName ?? 'default'];
    if (box != null) {
      await box.putAll(entries);
    }
  }

  Future<Map<dynamic, dynamic>> getAll({String? boxName}) async {
    final box = _boxes[boxName ?? 'default'];
    if (box == null) return {};
    return box.toMap();
  }

  Future<Iterable<dynamic>> getKeys({String? boxName}) async {
    final box = _boxes[boxName ?? 'default'];
    if (box == null) return [];
    return box.keys;
  }

  Future<Iterable<dynamic>> getValues({String? boxName}) async {
    final box = _boxes[boxName ?? 'default'];
    if (box == null) return [];
    return box.values;
  }

  Future<void> deleteFromDisk(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      await _boxes[boxName]!.close();
      _boxes.remove(boxName);
    }
    await Hive.deleteBoxFromDisk(boxName);
  }

  Future<void> deleteAllFromDisk() async {
    for (final boxName in _boxes.keys.toList()) {
      await deleteFromDisk(boxName);
    }
  }
}
