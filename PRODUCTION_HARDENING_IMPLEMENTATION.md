# 🚀 PRODUCTION HARDENING IMPLEMENTATION PLAN

**Status:** Ready to Execute  
**Order:** Strict (Error Handling → Pagination → Authorization → Loading/Empty States → Performance → Validation)  
**Estimated Time:** 35-40 hours  
**Priority:** Follows the exact sequence – no jumping around

---

## 📋 PHASE 1: ERROR HANDLING SYSTEM (3-4 hours)
**Goal:** NO MORE SILENT FAILURES – Every error shows user feedback

### Step 1.1: Backend – Standardize Exception Handler

**File:** `portfoliophhadmin/app/Exceptions/Handler.php`

```php
<?php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Validation\ValidationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Throwable;

class Handler extends ExceptionHandler
{
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            //
        });
    }

    /**
     * Render the exception into an HTTP response.
     * ALL exceptions → JSON response with consistent format
     */
    public function render($request, Throwable $exception)
    {
        // ✅ STEP 1: Force JSON response for API requests
        if ($this->isApiRequest($request)) {
            return $this->renderJsonResponse($request, $exception);
        }

        return parent::render($request, $exception);
    }

    /**
     * Check if request is to API endpoint
     */
    private function isApiRequest($request): bool
    {
        return $request->is('api/*') || $request->wantsJson();
    }

    /**
     * ✅ STEP 2: Map all exceptions to JSON
     * This is the heart of error handling
     */
    private function renderJsonResponse($request, Throwable $exception): JsonResponse
    {
        // Validation errors (422)
        if ($exception instanceof ValidationException) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'data' => null,
                'errors' => $exception->errors(),
            ], 422);
        }

        // Authentication errors (401)
        if ($exception instanceof AuthenticationException) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated. Please login.',
                'data' => null,
                'errors' => [],
            ], 401);
        }

        // HTTP exceptions (403, 404, 429, etc)
        if ($exception instanceof HttpException) {
            return response()->json([
                'success' => false,
                'message' => $this->getHttpExceptionMessage($exception->getStatusCode()),
                'data' => null,
                'errors' => [],
            ], $exception->getStatusCode() ?: 500);
        }

        // Generic server errors (500)
        $statusCode = 500;
        $message = 'Server error. Please try again later.';

        // In development, show the actual error
        if (app()->isLocal()) {
            $message = $exception->getMessage() ?: $message;
        }

        return response()->json([
            'success' => false,
            'message' => $message,
            'data' => null,
            'errors' => [],
        ], $statusCode);
    }

    /**
     * ✅ STEP 3: Human-readable error messages for common HTTP codes
     */
    private function getHttpExceptionMessage(int $statusCode): string
    {
        return match($statusCode) {
            400 => 'Bad request. Please check your input.',
            403 => 'You do not have permission to perform this action.',
            404 => 'Resource not found.',
            429 => 'Too many requests. Please try again later.',
            500 => 'Server error. Please try again later.',
            503 => 'Service unavailable. Please try again later.',
            default => 'An error occurred. Please try again.',
        };
    }
}
```

---

### Step 1.2: Backend – Verify Response Wrapper

**File:** `portfoliophhadmin/app/Http/Resources/ApiResponse.php`

Ensure this exists and matches:

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\JsonResponse;

class ApiResponse
{
    /**
     * ✅ Success response
     */
    public static function success(
        $data = null,
        string $message = 'Success',
        int $statusCode = 200
    ): JsonResponse {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
            'errors' => [],
        ], $statusCode);
    }

    /**
     * ✅ Error response
     */
    public static function error(
        string $message,
        int $statusCode = 400,
        array $errors = []
    ): JsonResponse {
        return response()->json([
            'success' => false,
            'message' => $message,
            'data' => null,
            'errors' => $errors,
        ], $statusCode);
    }

    /**
     * ✅ Paginated response
     */
    public static function paginated($data, string $message = 'Success', int $statusCode = 200): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
            'errors' => [],
        ], $statusCode);
    }
}
```

---

### Step 1.3: Frontend – Create Error Handler Service

**File:** `lib/core/services/error_handler.dart`

**NEW FILE – Create it:**

```dart
// lib/core/services/error_handler.dart
// ─────────────────────────────────────────────────────────────────────────────
// Global error handler that maps API errors to user-friendly messages
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';

class ErrorHandler {
  /// Maps DioException to user-friendly error message
  static String mapError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    }

    if (error.type == DioExceptionType.receiveTimeout) {
      return 'Server took too long to respond. Please try again.';
    }

    if (error.type == DioExceptionType.unknown) {
      return 'Network error. Please check your internet connection.';
    }

    // Has response from server
    if (error.response != null) {
      final statusCode = error.response!.statusCode ?? 0;
      final responseBody = error.response!.data;

      // Try to extract error message from response
      if (responseBody is Map<String, dynamic>) {
        final message = responseBody['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }

      // Map status codes to messages
      return mapStatusCodeToMessage(statusCode, responseBody);
    }

    return 'An error occurred. Please try again.';
  }

  /// Map HTTP status codes to user messages
  static String mapStatusCodeToMessage(int statusCode, dynamic responseBody) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 422:
        return _extractValidationErrors(responseBody);
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Extract validation error messages from 422 response
  static String _extractValidationErrors(dynamic responseBody) {
    if (responseBody is Map<String, dynamic>) {
      final errors = responseBody['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        // Get first error message
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first as String;
        }
      }
    }

    return 'Validation error. Please check your input.';
  }

  /// Check if error is authentication-related
  static bool isAuthError(DioException error) {
    return error.response?.statusCode == 401;
  }

  /// Check if error is validation-related
  static bool isValidationError(DioException error) {
    return error.response?.statusCode == 422;
  }

  /// Check if error is server-related
  static bool isServerError(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode != null && statusCode >= 500;
  }
}
```

---

### Step 1.4: Frontend – Create Toast/Snackbar Service

**File:** `lib/core/services/toast_service.dart`

**NEW FILE – Create it:**

```dart
// lib/core/services/toast_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Global toast/snackbar service for user feedback
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

enum ToastType { success, error, info, warning }

class ToastService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Show success toast
  static void showSuccess(String message) {
    _show(
      message: message,
      type: ToastType.success,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle,
    );
  }

  /// Show error toast
  static void showError(String message) {
    _show(
      message: message,
      type: ToastType.error,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,
    );
  }

  /// Show info toast
  static void showInfo(String message) {
    _show(
      message: message,
      type: ToastType.info,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info_outline,
    );
  }

  /// Show warning toast
  static void showWarning(String message) {
    _show(
      message: message,
      type: ToastType.warning,
      backgroundColor: Colors.orange.shade600,
      icon: Icons.warning_amber,
    );
  }

  /// Internal implementation
  static void _show({
    required String message,
    required ToastType type,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
```

---

### Step 1.5: Frontend – Update Dio Interceptor with Error Handling

**File:** `lib/core/services/api_service.dart`

**UPDATE – Replace error handler:**

```dart
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint('[ApiService] Error: ${error.message}');
    debugPrint('[ApiService] Status Code: ${error.response?.statusCode}');

    // ✅ NEW: If 401, clear token and logout
    if (error.response?.statusCode == 401) {
      await _secureStorage.delete(key: tokenKey);
      debugPrint('[ApiService] Token cleared – 401 Unauthorized');
      // App will automatically show login screen on next navigation
    }

    // ✅ Pass error to caller (they'll handle with ToastService)
    return handler.next(error);
  }
```

---

### Step 1.6: Frontend – Update Main App with Toast Service

**File:** `lib/main.dart`

**UPDATE – Add to MaterialApp:**

```dart
import 'package:portfolioph/core/services/toast_service.dart';

class App extends StatelessWidget {
  final ThemeProvider themeProvider;

  const App({Key? key, required this.themeProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ... existing config ...

      // ✅ ADD THIS:
      scaffoldMessengerKey: ToastService.scaffoldMessengerKey,

      routerConfig: AppRouter.router,
    );
  }
}
```

---

### Step 1.7: Frontend – Update Job Provider with Error Feedback

**File:** `lib/features/seeker/providers/seeker_job_list_provider.dart`

**UPDATE – Add error handling to all methods:**

```dart
import 'package:portfolioph/core/services/error_handler.dart';
import 'package:portfolioph/core/services/toast_service.dart';

class SeekerJobListProvider extends ChangeNotifier {
  // ... existing code ...

  Future<void> applyToJob(int jobId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _applicationRepository.createApplication(jobId: jobId);
      
      // ✅ Show success feedback
      ToastService.showSuccess('Application submitted successfully! ✅');
      
      notifyListeners();
    } on DioException catch (e) {
      // ✅ Map error and show user feedback
      final errorMessage = ErrorHandler.mapError(e);
      _errorMessage = errorMessage;
      ToastService.showError(errorMessage);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _jobs = await _jobRepository.getJobs();
      notifyListeners();
    } on DioException catch (e) {
      final errorMessage = ErrorHandler.mapError(e);
      _errorMessage = errorMessage;
      ToastService.showError(errorMessage);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

### Step 1.8: Verification Checklist

**Test the error handling:**

```
✅ Register with invalid email → Toast: "Invalid email format"
✅ Login with wrong password → Toast: "Invalid credentials"
✅ API down → Toast: "Server error. Please try again later."
✅ Network error → Toast: "Network error. Please check your internet."
✅ 422 validation error → Toast: Extract error message
✅ 401 auth error → Toast: "Session expired" + auto-logout
✅ Success action → Toast: "✅ Action completed"
```

---

## 📋 PHASE 2: PAGINATION (4-5 hours)
**Goal:** App doesn't crash with 1000+ records

### Step 2.1: Backend – Add Pagination to Job Endpoints

**File:** `portfoliophhadmin/app/Http/Controllers/JobController.php`

**UPDATE – index method:**

```php
    /**
     * Get all approved jobs with pagination
     */
    public function index(Request $request): JsonResponse
    {
        $perPage = $request->input('per_page', 15);
        $page = $request->input('page', 1);

        // ✅ Paginate instead of all()
        $jobs = Job::with('recruiter')
            ->where('status', 'approved')
            ->orderBy('created_at', 'desc')
            ->paginate($perPage, ['*'], 'page', $page);

        return ApiResponse::paginated(
            $jobs,
            'Jobs retrieved successfully',
            200
        );
    }
```

**UPDATE – also update ApplicationController:**

```php
    public function index(Request $request): JsonResponse
    {
        $perPage = $request->input('per_page', 15);
        
        // ✅ Paginate applications
        $applications = Application::with('job', 'user')
            ->where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);

        return ApiResponse::paginated(
            $applications,
            'Applications retrieved successfully',
            200
        );
    }
```

---

### Step 2.2: Frontend – Create Pagination Provider

**File:** `lib/features/seeker/providers/seeker_job_list_provider.dart`

**NEW/UPDATE – Add pagination state:**

```dart
class SeekerJobListProvider extends ChangeNotifier {
  final JobRepository _jobRepository;

  List<JobModel> _jobs = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // ✅ NEW: Pagination state
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _hasMoreData = true;

  SeekerJobListProvider({JobRepository? jobRepository})
      : _jobRepository = jobRepository ?? JobRepository();

  // Getters
  List<JobModel> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  /// ✅ Load first page
  Future<void> loadJobs() async {
    _currentPage = 1;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _jobRepository.getJobsPaginated(page: 1);

      _jobs = response['jobs'] as List<JobModel>;
      _currentPage = response['current_page'] as int;
      _lastPage = response['last_page'] as int;
      _total = response['total'] as int;
      _hasMoreData = _currentPage < _lastPage;

      _errorMessage = null;
      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = ErrorHandler.mapError(e);
      ToastService.showError(_errorMessage!);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Load next page (append to list)
  Future<void> loadMoreJobs() async {
    if (!_hasMoreData || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _jobRepository.getJobsPaginated(page: nextPage);

      final newJobs = response['jobs'] as List<JobModel>;
      _jobs.addAll(newJobs);  // ✅ Append, don't replace
      _currentPage = response['current_page'] as int;
      _lastPage = response['last_page'] as int;
      _hasMoreData = _currentPage < _lastPage;

      notifyListeners();
    } on DioException catch (e) {
      _errorMessage = ErrorHandler.mapError(e);
      ToastService.showError('Failed to load more jobs');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Refresh (reload from page 1)
  Future<void> refresh() => loadJobs();
}
```

---

### Step 2.3: Frontend – Update Job Repository with Pagination Method

**File:** `lib/data/repositories/job_repository.dart`

**UPDATE/ADD:**

```dart
import 'package:dio/dio.dart';

class JobRepository {
  final ApiService _apiService;

  JobRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService(const FlutterSecureStorage());

  /// ✅ NEW: Get jobs with pagination
  Future<Map<String, dynamic>> getJobsPaginated({
    int page = 1,
    int perPage = 15,
  }) async {
    const endpoint = '/jobs';

    try {
      final response = await _apiService.get(
        endpoint,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final paginatedData = response['data'] as Map<String, dynamic>;

        // Parse job list
        final jobsData = paginatedData['data'] as List;
        final jobs = jobsData
            .map((job) => JobModel.fromJson(job as Map<String, dynamic>))
            .toList();

        return {
          'jobs': jobs,
          'current_page': paginatedData['current_page'] as int,
          'last_page': paginatedData['last_page'] as int,
          'total': paginatedData['total'] as int,
        };
      }

      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  /// Existing method (keep for backward compatibility)
  Future<List<JobModel>> getJobs() async {
    const endpoint = '/jobs';

    try {
      final response = await _apiService.get(endpoint);

      if (response['success'] == true && response['data'] != null) {
        final jobsData = response['data'] as List;
        return jobsData
            .map((job) => JobModel.fromJson(job as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }
}
```

---

### Step 2.4: Frontend – Implement Infinite Scroll UI

**File:** `lib/presentation/screens/seeker/screens/jobs_list_screen.dart`

**UPDATE – Add infinite scroll:**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolioph/features/seeker/providers/seeker_job_list_provider.dart';
import 'package:portfolioph/core/services/toast_service.dart';

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({Key? key}) : super(key: key);

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // ✅ Load first page on init
    Future.microtask(() {
      context.read<SeekerJobListProvider>().loadJobs();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// ✅ Called when user scrolls to bottom
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      // User is within 500px of bottom → load more
      context.read<SeekerJobListProvider>().loadMoreJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Jobs')),
      body: Consumer<SeekerJobListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.jobs.isEmpty && !provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.work_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No jobs available yet'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    onPressed: () => provider.refresh(),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.jobs.length + (provider.hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                // ✅ Show loading indicator at bottom
                if (index == provider.jobs.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: provider.isLoading
                          ? const CircularProgressIndicator()
                          : const SizedBox.shrink(),
                    ),
                  );
                }

                final job = provider.jobs[index];
                return JobCard(job: job);
              },
            ),
          );
        },
      ),
    );
  }
}

// Simple job card widget
class JobCard extends StatelessWidget {
  final JobModel job;

  const JobCard({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(job.title),
        subtitle: Text(job.description ?? ''),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // Navigate to job details
        },
      ),
    );
  }
}
```

---

### Step 2.5: Backend – Database Migration (Add If Needed)

If your jobs table doesn't have an `order by` index, add:

**File:** `portfoliophhadmin/database/migrations/XXXX_XX_XX_XXXXXX_add_indexes_to_jobs_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('jobs', function (Blueprint $table) {
            // ✅ Add indexes for pagination queries
            $table->index('status');
            $table->index('created_at');
            $table->index('recruiter_id');
        });
    }

    public function down(): void
    {
        Schema::table('jobs', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropIndex(['created_at']);
            $table->dropIndex(['recruiter_id']);
        });
    }
};
```

Run:
```bash
php artisan migrate
```

---

### Step 2.6: Verification Checklist

```
✅ Fetch /api/jobs?page=1&per_page=15 → Returns paginated response
✅ Response has: data[], current_page, last_page, total
✅ Load first 15 jobs in Flutter
✅ Scroll to bottom → Load more jobs appears
✅ Scroll to bottom → Next 15 jobs append (not replace)
✅ All 30 jobs now visible in list
✅ Pull-to-refresh reloads page 1
✅ Large dataset (1000 jobs) doesn't crash
```

---

## 📋 PHASE 3: AUTHORIZATION (2-3 hours)
**Goal:** Users can only modify their own data

### Step 3.1: Backend – Create Job Policy

```bash
php artisan make:policy JobPolicy --model=Job
```

**File:** `portfoliophhadmin/app/Policies/JobPolicy.php`

```php
<?php

namespace App\Policies;

use App\Models\Job;
use App\Models\User;

class JobPolicy
{
    /**
     * Determine if user can update job
     * Only recruiter who created it can update
     */
    public function update(User $user, Job $job): bool
    {
        return $user->id === $job->recruiter_id;
    }

    /**
     * Determine if user can delete job
     * Only recruiter who created it can delete
     */
    public function delete(User $user, Job $job): bool
    {
        return $user->id === $job->recruiter_id;
    }

    /**
     * Determine if user can view job details
     * Anyone can view approved jobs
     */
    public function view(User $user, Job $job): bool
    {
        return $job->status === 'approved';
    }
}
```

---

### Step 3.2: Backend – Create Application Policy

```bash
php artisan make:policy ApplicationPolicy --model=Application
```

**File:** `portfoliophhadmin/app/Policies/ApplicationPolicy.php`

```php
<?php

namespace App\Policies;

use App\Models\Application;
use App\Models\User;

class ApplicationPolicy
{
    /**
     * User can only view their own applications
     */
    public function view(User $user, Application $application): bool
    {
        return $user->id === $application->user_id;
    }

    /**
     * User can only update their own applications
     */
    public function update(User $user, Application $application): bool
    {
        return $user->id === $application->user_id;
    }

    /**
     * User can only delete their own applications
     */
    public function delete(User $user, Application $application): bool
    {
        return $user->id === $application->user_id;
    }
}
```

---

### Step 3.3: Backend – Register Policies

**File:** `portfoliophhadmin/app/Providers/AuthServiceProvider.php`

```php
<?php

namespace App\Providers;

use App\Models\Job;
use App\Models\Application;
use App\Policies\JobPolicy;
use App\Policies\ApplicationPolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * ✅ Register policies
     */
    protected $policies = [
        Job::class => JobPolicy::class,
        Application::class => ApplicationPolicy::class,
    ];

    public function boot(): void
    {
        //
    }
}
```

---

### Step 3.4: Backend – Apply Authorization Checks in Controllers

**File:** `portfoliophhadmin/app/Http/Controllers/JobController.php`

**UPDATE – update() and destroy() methods:**

```php
    /**
     * Update job (auth check + ownership check)
     */
    public function update(UpdateJobRequest $request, Job $job): JsonResponse
    {
        // ✅ Check ownership with policy
        $this->authorize('update', $job);

        $updated = $this->jobService->updateJob($job, $request->validated());

        return ApiResponse::success(
            $updated,
            'Job updated successfully',
            200
        );
    }

    /**
     * Delete job (auth check + ownership check)
     */
    public function destroy(Job $job): JsonResponse
    {
        // ✅ Check ownership with policy
        $this->authorize('delete', $job);

        $this->jobService->deleteJob($job);

        return ApiResponse::success(
            null,
            'Job deleted successfully',
            200
        );
    }
```

**File:** `portfoliophhadmin/app/Http/Controllers/ApplicationController.php`

```php
    public function show(Application $application): JsonResponse
    {
        // ✅ Check ownership
        $this->authorize('view', $application);

        return ApiResponse::success(
            $application,
            'Application retrieved successfully'
        );
    }

    public function updateStatus(Request $request, Application $application): JsonResponse
    {
        // ✅ Only recruiter of the job can update application status
        $this->authorize('update', $application);

        $validated = $request->validate([
            'status' => 'required|in:pending,approved,rejected',
        ]);

        $application->update($validated);

        return ApiResponse::success(
            $application,
            'Application status updated'
        );
    }
```

---

### Step 3.5: Verification Checklist

```
✅ User A creates Job 1
✅ User B tries: PUT /api/jobs/1 → 403 Forbidden
✅ User A tries: PUT /api/jobs/1 → 200 OK (updated)
✅ User B applies for Job 1 → 201 Created (Application created)
✅ User B tries: GET /api/applications/{id} → 200 OK (own application)
✅ User A tries: GET /api/applications/{id} → 403 Forbidden
✅ Manually apply policy by role check
```

---

## 📋 PHASE 4: LOADING + EMPTY STATES (3-4 hours)
**Goal:** Professional UX – never show blank screens

### Step 4.1: Create Skeleton Loader Widget

**File:** `lib/presentation/widgets/common/skeleton_loader.dart`

**NEW FILE:**

```dart
// lib/presentation/widgets/common/skeleton_loader.dart
// ─────────────────────────────────────────────────────────────────────────────
// Animated skeleton loader for professional loading states
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    Key? key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade300,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for a job card (list item)
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(height: 20, width: 200),
            const SizedBox(height: 12),
            SkeletonLoader(height: 16, width: double.infinity),
            const SizedBox(height: 8),
            SkeletonLoader(height: 16, width: 250),
            const SizedBox(height: 12),
            Row(
              children: [
                SkeletonLoader(height: 12, width: 80),
                const SizedBox(width: 16),
                SkeletonLoader(height: 12, width: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Build a list of skeleton loaders
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function()? itemBuilder;

  const SkeletonList({
    Key? key,
    this.itemCount = 5,
    this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return itemBuilder?.call() ?? const JobCardSkeleton();
      },
    );
  }
}
```

---

### Step 4.2: Create Empty State Widget

**File:** `lib/presentation/widgets/common/empty_state_widget.dart`

**UPDATE:**

```dart
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (buttonLabel != null && onButtonPressed != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(buttonLabel!),
              onPressed: onButtonPressed,
            ),
          ],
        ],
      ),
    );
  }
}
```

---

### Step 4.3: Update Jobs List Screen with Loading/Empty States

**File:** `lib/presentation/screens/seeker/screens/jobs_list_screen.dart`

**UPDATE – Replace build() method:**

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Jobs')),
      body: Consumer<SeekerJobListProvider>(
        builder: (context, provider, child) {
          // ✅ LOADING STATE (first load)
          if (provider.isLoading && provider.jobs.isEmpty) {
            return SkeletonList(
              itemCount: 5,
              itemBuilder: () => const JobCardSkeleton(),
            );
          }

          // ✅ EMPTY STATE (no jobs)
          if (provider.jobs.isEmpty && !provider.isLoading) {
            return EmptyStateWidget(
              icon: Icons.work_outline,
              title: 'No Jobs Available',
              message: 'Check back soon for new opportunities!',
              buttonLabel: 'Refresh',
              onButtonPressed: () => provider.refresh(),
            );
          }

          // ✅ LOADED STATE (show list)
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.jobs.length + (provider.hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator while fetching next page
                if (index == provider.jobs.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: provider.isLoading
                          ? const CircularProgressIndicator()
                          : const SizedBox.shrink(),
                    ),
                  );
                }

                final job = provider.jobs[index];
                return JobCard(job: job);
              },
            ),
          );
        },
      ),
    );
  }
```

---

### Step 4.4: Create Empty State for Admin Dashboard

**File:** `lib/presentation/screens/admin/filament_admin_screen.dart`

**UPDATE – Add to dashboard:**

```dart
class AdminDashboardContent extends StatelessWidget {
  final AdminProvider adminProvider;

  const AdminDashboardContent({
    Key? key,
    required this.adminProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (adminProvider.isLoading) {
      // ✅ Show loading state
      return SingleChildScrollView(
        child: Column(
          children: [
            SkeletonLoader(height: 200, borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 16),
            SkeletonLoader(height: 200, borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 16),
            SkeletonLoader(height: 300, borderRadius: BorderRadius.circular(8)),
          ],
        ),
      );
    }

    if (adminProvider.pendingJobs.isEmpty) {
      // ✅ Show empty state
      return EmptyStateWidget(
        icon: Icons.dashboard_outlined,
        title: 'No Pending Jobs',
        message: 'All jobs have been reviewed. Great work!',
      );
    }

    // ✅ Show dashboard
    return SingleChildScrollView(
      child: Column(
        children: [
          // Dashboard content
        ],
      ),
    );
  }
}
```

---

### Step 4.5: Verify Loading States

**Update index exports:**

**File:** `lib/presentation/widgets/common/index.dart`

```dart
export 'loading_widget.dart';
export 'app_error_widget.dart';
export 'empty_state_widget.dart';
export 'skeleton_loader.dart';
```

---

## 📋 PHASE 5: PERFORMANCE OPTIMIZATION (1-2 hours)
**Goal:** Fast, responsive queries

### Step 5.1: Backend – Add Eager Loading

**File:** `portfoliophhadmin/app/Http/Controllers/JobController.php`

**UPDATE:**

```php
    public function index(Request $request): JsonResponse
    {
        $perPage = $request->input('per_page', 15);

        // ✅ Eager load relationships
        $jobs = Job::with('recruiter')  // Load recruiter in single query
            ->where('status', 'approved')
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);

        return ApiResponse::paginated($jobs, 'Jobs retrieved successfully');
    }

    public function show(Job $job): JsonResponse
    {
        // ✅ Load related data
        $jobData = Job::with('recruiter', 'applications.user')
            ->findOrFail($job->id);

        return ApiResponse::success($jobData, 'Job retrieved successfully');
    }
```

**File:** `portfoliophhadmin/app/Http/Controllers/ApplicationController.php`

```php
    public function index(Request $request): JsonResponse
    {
        $perPage = $request->input('per_page', 15);

        // ✅ Eager load job and recruiter
        $applications = Application::with('job', 'user')
            ->where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);

        return ApiResponse::paginated($applications, 'Applications retrieved');
    }
```

---

### Step 5.2: Backend – Add Database Indexes

Create migration:

```bash
php artisan make:migration add_performance_indexes
```

**File:** `portfoliophhadmin/database/migrations/XXXX_XX_XX_XXXXXX_add_performance_indexes.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('jobs', function (Blueprint $table) {
            $table->index('status');
            $table->index('recruiter_id');
            $table->index('created_at');
            $table->index(['recruiter_id', 'status']);  // Composite index
        });

        Schema::table('applications', function (Blueprint $table) {
            $table->index('user_id');
            $table->index('job_id');
            $table->index('status');
            $table->index('created_at');
            $table->index(['job_id', 'user_id']);  // Composite index
        });

        Schema::table('users', function (Blueprint $table) {
            $table->index('email');
            $table->index('role');
        });
    }

    public function down(): void
    {
        Schema::table('jobs', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropIndex(['recruiter_id']);
            $table->dropIndex(['created_at']);
            $table->dropIndex(['recruiter_id', 'status']);
        });

        Schema::table('applications', function (Blueprint $table) {
            $table->dropIndex(['user_id']);
            $table->dropIndex(['job_id']);
            $table->dropIndex(['status']);
            $table->dropIndex(['created_at']);
            $table->dropIndex(['job_id', 'user_id']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['email']);
            $table->dropIndex(['role']);
        });
    }
};
```

Run:
```bash
php artisan migrate
```

---

## 📋 PHASE 6: VALIDATION HARDENING (1-2 hours)
**Goal:** Strong validation, prevent bad data

### Step 6.1: Verify/Create FormRequest Classes

**File:** `php artisan make:request StoreJobRequest`

**File:** `portfoliophhadmin/app/Http/Requests/StoreJobRequest.php`

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreJobRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;  // Auth checked in controller
    }

    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'description' => 'required|string|max:2000',
            'location' => 'required|string|max:255',
            'salary_range' => 'required|string|max:100',
            'job_type' => 'required|in:full-time,part-time,contract,freelance',
            'requirements' => 'nullable|array',
            'requirements.*' => 'string|max:255',
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'Job title is required.',
            'title.max' => 'Job title cannot exceed 255 characters.',
            'description.required' => 'Job description is required.',
            'description.max' => 'Job description cannot exceed 2000 characters.',
            'location.required' => 'Location is required.',
            'salary_range.required' => 'Salary range is required.',
            'job_type.required' => 'Job type is required.',
            'job_type.in' => 'Invalid job type selected.',
        ];
    }
}
```

**File:** `portfoliophhadmin/app/Http/Requests/UpdateJobRequest.php`

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateJobRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string|max:2000',
            'location' => 'sometimes|string|max:255',
            'salary_range' => 'sometimes|string|max:100',
            'job_type' => 'sometimes|in:full-time,part-time,contract,freelance',
        ];
    }
}
```

---

## ✅ FINAL CHECKLIST

### Error Handling ✅
- [ ] Handler.php catches all exceptions
- [ ] All API responses follow format: {success, message, data, errors}
- [ ] Dio interceptor on 401 → clears token
- [ ] Toast service shows success/error/info messages
- [ ] Test: API error shows Toast to user

### Pagination ✅
- [ ] Backend endpoints return paginated response
- [ ] Frontend provider tracks current_page, last_page
- [ ] Infinite scroll loads next page
- [ ] New data appends to list (doesn't replace)
- [ ] Test: 100+ records load without crash

### Authorization ✅
- [ ] Job policy: only owner can update/delete
- [ ] Application policy: only user who applied can view
- [ ] Controller uses $this->authorize()
- [ ] 403 response for unauthorized actions
- [ ] Test: User B can't delete User A's job

### Loading/Empty States ✅
- [ ] Skeleton loaders show while loading
- [ ] Empty state shows when no data
- [ ] CTA button to create/refresh
- [ ] No blank screens ever
- [ ] Test: Visually pleasant loading experience

### Performance ✅
- [ ] Eager loading: with('relationship')
- [ ] Database indexes on foreign keys
- [ ] Composite indexes for common queries
- [ ] Test: Query time <100ms

### Validation ✅
- [ ] FormRequest validates all inputs
- [ ] Custom error messages
- [ ] 422 response with error details
- [ ] Frontend shows validation errors
- [ ] Test: Invalid input rejected with message

---

## 🧪 RUNTIME TEST PLAN

After implementation, test each flow:

```
TEST 1: Registration → Login → Dashboard
✅ Register new user
✅ Login with credentials
✅ Dashboard loads (no blank screen)
✅ Session persists on app restart

TEST 2: Create Job
✅ Fill form → submit
✅ Toast: "Job created ✅"
✅ Job appears in list immediately

TEST 3: Browse Jobs (Pagination)
✅ Load 15 jobs
✅ Scroll to bottom
✅ Next 15 jobs load
✅ Total 30 jobs visible

TEST 4: Apply for Job
✅ Click apply → submit
✅ Toast: "Application submitted ✅"
✅ Application saved in DB

TEST 5: Authorization
✅ User A creates Job 1
✅ User B tries to DELETE /jobs/1
✅ Toast: "You don't have permission"
✅ No deletion occurs

TEST 6: Error Handling
✅ API down → Toast with error message
✅ Invalid token → Auto-logout
✅ Network error → Toast "Check internet"
✅ Server error → Toast "Try again later"

TEST 7: Empty States
✅ New user with no applications → Empty state shown
✅ CTA button to create job
✅ Not a blank confusing screen

TEST 8: Loading States
✅ Page loads → Skeleton loaders appear
✅ Data arrives → Skeletons replaced with content
✅ Smooth, professional experience
```

---

## 🎓 IMPLEMENTATION ORDER (STRICT)

1. ✅ Error Handling System (Phase 1) – 3-4h
2. ✅ Pagination (Phase 2) – 4-5h
3. ✅ Authorization (Phase 3) – 2-3h
4. ✅ Loading + Empty States (Phase 4) – 3-4h
5. ✅ Performance Optimization (Phase 5) – 1-2h
6. ✅ Validation Hardening (Phase 6) – 1-2h

**Total: 15-20 hours to production-grade**

---

**NEXT STEP:** Start with Phase 1 – Error Handling System. Don't move to Phase 2 until Phase 1 is complete and tested.
