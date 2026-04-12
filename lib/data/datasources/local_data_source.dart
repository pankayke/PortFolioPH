import 'package:portfolioph/data/services/local_storage_service.dart';

/// Local Data Source
///
/// Handles all local data operations using SQLite or SharedPreferences
abstract class LocalDataSource {
  Future<void> saveItem({
    required String namespace,
    required String id,
    required Map<String, dynamic> data,
  });

  Future<Map<String, dynamic>?> getItem({
    required String namespace,
    required String id,
  });

  Future<List<Map<String, dynamic>>> getItems({required String namespace});

  Future<void> deleteItem({required String namespace, required String id});

  Future<void> clearNamespace(String namespace);
}

class LocalDataSourceImpl implements LocalDataSource {
  LocalDataSourceImpl({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  String _indexKey(String namespace) => 'lds:$namespace:index';
  String _itemKey(String namespace, String id) => 'lds:$namespace:item:$id';

  @override
  Future<void> saveItem({
    required String namespace,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _storage.setJson(_itemKey(namespace, id), data);

    final ids =
        await _storage.getStringList(_indexKey(namespace)) ?? <String>[];
    if (!ids.contains(id)) {
      ids.add(id);
      await _storage.setStringList(_indexKey(namespace), ids);
    }
  }

  @override
  Future<Map<String, dynamic>?> getItem({
    required String namespace,
    required String id,
  }) {
    return _storage.getJson(_itemKey(namespace, id));
  }

  @override
  Future<List<Map<String, dynamic>>> getItems({
    required String namespace,
  }) async {
    final ids =
        await _storage.getStringList(_indexKey(namespace)) ?? const <String>[];
    final result = <Map<String, dynamic>>[];

    for (final id in ids) {
      final item = await _storage.getJson(_itemKey(namespace, id));
      if (item != null) result.add(item);
    }

    return result;
  }

  @override
  Future<void> deleteItem({
    required String namespace,
    required String id,
  }) async {
    await _storage.remove(_itemKey(namespace, id));

    final ids =
        await _storage.getStringList(_indexKey(namespace)) ?? <String>[];
    ids.remove(id);
    await _storage.setStringList(_indexKey(namespace), ids);
  }

  @override
  Future<void> clearNamespace(String namespace) async {
    final ids =
        await _storage.getStringList(_indexKey(namespace)) ?? const <String>[];
    for (final id in ids) {
      await _storage.remove(_itemKey(namespace, id));
    }
    await _storage.remove(_indexKey(namespace));
  }
}
