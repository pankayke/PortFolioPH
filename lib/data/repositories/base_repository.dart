/// Base Repository
///
/// Abstract base class for all repositories
abstract class BaseRepository {
  Future<T> guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      rethrow;
    }
  }

  String asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final out = value.toString();
    return out.isEmpty ? fallback : out;
  }

  int asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  double? asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
