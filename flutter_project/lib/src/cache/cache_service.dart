abstract class CacheService {
  Future<bool> containsKey(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<int> size();
}
