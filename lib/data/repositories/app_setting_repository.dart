import 'package:portfolioph/data/datasources/local_data_source.dart';
import 'package:portfolioph/data/models/app_setting_model.dart';

/// App Setting Repository
///
/// Repository for app settings
abstract class AppSettingRepository {
  Future<List<AppSettingModel>> getAllForUser(int userId);

  Future<AppSettingModel?> getByKey({
    required int userId,
    required String key,
  });

  Future<AppSettingModel> upsert({
    required int userId,
    required String key,
    required String value,
  });

  Future<void> deleteByKey({
    required int userId,
    required String key,
  });

  Future<void> clearForUser(int userId);
}

class AppSettingRepositoryImpl implements AppSettingRepository {
  AppSettingRepositoryImpl({LocalDataSource? localDataSource})
    : _local = localDataSource ?? LocalDataSourceImpl();

  final LocalDataSource _local;

  String _namespace(int userId) => 'app_settings:$userId';

  @override
  Future<List<AppSettingModel>> getAllForUser(int userId) async {
    final items = await _local.getItems(namespace: _namespace(userId));
    return items.map(AppSettingModel.fromMap).toList(growable: false);
  }

  @override
  Future<AppSettingModel?> getByKey({
    required int userId,
    required String key,
  }) async {
    final item = await _local.getItem(namespace: _namespace(userId), id: key);
    if (item == null) return null;
    return AppSettingModel.fromMap(item);
  }

  @override
  Future<AppSettingModel> upsert({
    required int userId,
    required String key,
    required String value,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final model = AppSettingModel(
      userId: userId,
      settingKey: key,
      settingValue: value,
      updatedAt: now,
    );

    await _local.saveItem(
      namespace: _namespace(userId),
      id: key,
      data: model.toMap(),
    );

    return model;
  }

  @override
  Future<void> deleteByKey({
    required int userId,
    required String key,
  }) {
    return _local.deleteItem(namespace: _namespace(userId), id: key);
  }

  @override
  Future<void> clearForUser(int userId) {
    return _local.clearNamespace(_namespace(userId));
  }
}
