/// Cache Manager
///
/// Handles caching and cache operations
class CacheManager {
  CacheManager._();

  static final Map<String, _CacheEntry<dynamic>> _cache =
      <String, _CacheEntry<dynamic>>{};

  static void set<T>(
    String key,
    T value, {
    Duration? ttl,
  }) {
    _cache[key] = _CacheEntry<T>(
      value: value,
      expiresAt: ttl == null ? null : DateTime.now().add(ttl),
    );
  }

  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T;
  }

  static bool contains(String key) => get<dynamic>(key) != null;

  static void remove(String key) {
    _cache.remove(key);
  }

  static void clear() {
    _cache.clear();
  }

  static int pruneExpired() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList(growable: false);

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    return expiredKeys.length;
  }

  static int get size {
    pruneExpired();
    return _cache.length;
  }
}

class _CacheEntry<T> {
  const _CacheEntry({
    required this.value,
    required this.expiresAt,
  });

  final T value;
  final DateTime? expiresAt;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
