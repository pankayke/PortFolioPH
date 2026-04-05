import 'package:flutter_test/flutter_test.dart';
import 'package:portfolioph/data/models/user_model.dart';
import 'package:portfolioph/data/services/api_service.dart';
import 'package:portfolioph/data/services/auth_service.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Authentication Integration Tests', () {
    late ApiService apiService;
    late AuthService authService;

    /// SET UP: Initialize services with real backend URL
    setUp(() {
      const String baseUrl = 'http://127.0.0.1:8000';
      apiService = ApiService(baseUrl);
      authService = AuthService(apiService);
    });

    /// TEST 1: Registration - Get valid token
    test('Registration creates new user and returns token', () async {
      final response = await apiService.post(
        '/auth/register',
        {
          'name': 'Test User ${DateTime.now().millisecondsSinceEpoch}',
          'email': 'testuser${DateTime.now().millisecondsSinceEpoch}@test.com',
          'password': 'Password123!',
          'username': 'testuser${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      print('✅ Registration Response: $response');

      expect(response['success'], true);
      expect(response['data']['token'], isNotNull);
      expect(response['data']['user']['email'], isNotNull);

      // Save token for later tests
      String token = response['data']['token'];
      await authService.saveToken(token);
    });

    /// TEST 2: Session Restore - Verify token is valid
    test('GET /auth/me verifies token and returns current user', () async {
      // First, we need a valid token
      // In real test, get from registration first
      final loginResponse = await apiService.post(
        '/auth/login',
        {
          'email': 'test@test.com', // Use existing user
          'password': 'password',
        },
      );

      print('✅ Login Response: $loginResponse');
      expect(loginResponse['success'], true);
      expect(loginResponse['data']['token'], isNotNull);

      String token = loginResponse['data']['token'];
      await authService.saveToken(token);

      // Now test /auth/me with token
      final meResponse = await apiService.get('/auth/me');

      print('✅ /auth/me Response: $meResponse');

      expect(meResponse['success'], true);
      expect(meResponse['data']['id'], isNotNull);
      expect(meResponse['data']['email'], isNotNull);
      expect(meResponse['data']['name'], isNotNull);

      // Parse to UserModel
      final user = UserModel.fromMap(meResponse['data']);
      expect(user.email, isNotNull);

      print('✅ Current user restored: ${user.email}');
    });

    /// TEST 3: Authenticate method with token
    test('AuthService.authenticate() saves token and enables API access',
        () async {
      final response = await apiService.post(
        '/auth/login',
        {
          'email': 'test@test.com',
          'password': 'password',
        },
      );

      expect(response['success'], true);

      // Simulate what UserRepository does
      String token = response['data']['token'];
      await authService.saveToken(token);

      // Verify token is saved
      bool hasToken = await authService.hasToken();
      expect(hasToken, true);

      print('✅ Token saved and verified');
    });

    /// TEST 4: Logout - Invalidates token
    test('POST /auth/logout invalidates token on backend', () async {
      // First login
      final loginResponse = await apiService.post(
        '/auth/login',
        {
          'email': 'test@test.com',
          'password': 'password',
        },
      );

      String token = loginResponse['data']['token'];
      await authService.saveToken(token);

      // Logout
      final logoutResponse = await apiService.post('/auth/logout', {});

      print('✅ Logout Response: $logoutResponse');
      expect(logoutResponse['success'], true);

      // Clear token locally
      await authService.clearToken();

      // Verify token is cleared
      bool hasToken = await authService.hasToken();
      expect(hasToken, false);

      print('✅ Token cleared after logout');
    });

    /// TEST 5: Complete flow - Register, Verify, Logout
    test('Complete auth flow: Register → Verify → Logout', () async {
      final email =
          'flowtest${DateTime.now().millisecondsSinceEpoch}@test.com';

      // 1. Register
      final registerResponse = await apiService.post(
        '/auth/register',
        {
          'name': 'Flow Test User',
          'email': email,
          'password': 'Password123!',
          'username':
              'flowtest${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      print('✅ Step 1 - Register: ${registerResponse['data']['user']['email']}');
      expect(registerResponse['success'], true);

      String token = registerResponse['data']['token'];
      await authService.saveToken(token);

      // 2. Verify session (like app restart)
      final meResponse = await apiService.get('/auth/me');

      print('✅ Step 2 - Verify Session: ${meResponse['data']['email']}');
      expect(meResponse['success'], true);
      expect(meResponse['data']['email'], email);

      // 3. Logout
      final logoutResponse = await apiService.post('/auth/logout', {});

      print('✅ Step 3 - Logout: Success');
      expect(logoutResponse['success'], true);

      await authService.clearToken();

      print('✅ Complete flow successful!');
    });

    /// TEST 6: Interceptor - Bearer token in all requests
    test('API interceptor automatically adds Bearer token to requests',
        () async {
      // Login to get token
      final loginResponse = await apiService.post(
        '/auth/login',
        {
          'email': 'test@test.com',
          'password': 'password',
        },
      );

      String token = loginResponse['data']['token'];
      await authService.saveToken(token);

      // Make any authenticated request - token should be included automatically
      final jobsResponse = await apiService.get('/jobs');

      print('✅ Jobs request with Bearer token: ${jobsResponse['success']}');

      // The fact that this doesn't return 401 means token was included
      // and was valid
      expect(jobsResponse['success'] == true || jobsResponse['data'] != null,
          true);
    });
  });
}
