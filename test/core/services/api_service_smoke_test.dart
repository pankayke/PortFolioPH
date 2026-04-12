import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:portfolioph/core/config/app_config.dart';
import 'package:portfolioph/core/services/api_service.dart';

void main() {
  late ApiService apiService;

  setUp(() {
    AppConfig.initialize(Flavor.development);
    FlutterSecureStorage.setMockInitialValues({});
    apiService = ApiService(const FlutterSecureStorage());
  });

  test('token lifecycle methods work end-to-end', () async {
    expect(await apiService.hasToken(), isFalse);
    expect(await apiService.getToken(), isNull);

    await apiService.saveToken('smoke-token');

    expect(await apiService.hasToken(), isTrue);
    expect(await apiService.getToken(), 'smoke-token');

    await apiService.clearToken();

    expect(await apiService.hasToken(), isFalse);
    expect(await apiService.getToken(), isNull);
  });
}
