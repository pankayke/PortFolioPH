import '../models/user_model.dart';
import '../../core/services/api_service.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository(this.apiService);

  Future<(UserModel user, String token)> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? companyName,
    String? companyWebsite,
    String? phone,
  }) async {
    final response = await apiService.register(
      name: name,
      email: email,
      password: password,
      role: role,
      companyName: companyName,
      companyWebsite: companyWebsite,
      phone: phone,
    );

    final user = UserModel.fromJson(response['user']);
    final token = (response['token'] as String?) ?? '';

    return (user, token);
  }

  Future<(UserModel user, String token)> login({
    required String email,
    required String password,
  }) async {
    final response = await apiService.login(email: email, password: password);

    final user = UserModel.fromJson(response['user']);
    final token = (response['token'] as String?) ?? '';

    return (user, token);
  }

  Future<void> logout() async {
    await apiService.logout();
  }

  Future<UserModel> getMe() async {
    final response = await apiService.getMe();
    return UserModel.fromJson(response['user']);
  }

  Future<bool> hasToken() async {
    return await apiService.hasToken();
  }
}
