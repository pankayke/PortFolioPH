import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../core/services/api_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/job_repository.dart';
import 'auth_provider.dart';
import 'job_provider.dart';

class AppProviders {
  static List<SingleChildWidget> get providers {
    // Create API Service
    final apiService = ApiService();

    return [
      // Services
      Provider<ApiService>(create: (_) => apiService),

      // Repositories
      Provider<AuthRepository>(create: (context) => AuthRepository(apiService)),
      Provider<JobRepository>(create: (context) => JobRepository(apiService)),

      // Providers
      ChangeNotifierProvider<AuthProvider>(
        create: (context) => AuthProvider(context.read<AuthRepository>()),
      ),
      ChangeNotifierProvider<JobProvider>(
        create: (context) => JobProvider(context.read<JobRepository>()),
      ),
    ];
  }
}
