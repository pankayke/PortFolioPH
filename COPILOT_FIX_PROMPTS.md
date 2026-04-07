# 🎯 ACTIONABLE FIX PROMPTS FOR GITHUB COPILOT

**How to Use This Document:**  
For each issue below, copy the prompt into GitHub Copilot Chat and paste it directly. Copilot will generate targeted fixes.

---

## PRIORITY 1: UNBLOCK THE INTEGRATION (1-2 hours)

### Prompt 1.1: Implement Real API Service

**Copy-paste this prompt:**

```
I have a Flutter app that currently has an empty ApiService stub at 
lib/data/services/api_service.dart with only a TODO comment.

The app needs to make real HTTP calls to a Laravel backend at 
http://localhost:8000/api.

Requirements:
1. Use Dio package for HTTP client (already in pubspec.yaml)
2. Base URL: http://localhost:8000/api
3. Timeout: 30 seconds
4. Endpoints needed:
   - POST /auth/register (email, password, name) → returns {token, user}
   - POST /auth/login (email, password) → returns {token, user}
   - GET /jobs (pagination: page, limit) → returns {data: [...], total}
   - GET /jobs/{id} → returns {data: {...}}
   - POST /jobs (title, description, location, salary_min, salary_max, job_type, deadline) → returns {data: {...}}
   - POST /applications (job_id, cover_letter) → returns {data: {...}}
   - GET /applications (page, limit) → returns {data: [...]}
   - GET /users/{id} → returns {data: {...}}

5. Error handling: throw specific exceptions (UnauthorizedException, NotFoundException, NetworkException)
6. Add request/response logging in debug mode

Generate the complete ApiService implementation. Follow this structure:
```dart
class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8000/api',
      timeout: Duration(seconds: 30),
    ));

    // Add interceptors for auth, logging, error handling
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register({required String email, required String password, required String name}) async {
    // Implementation
  }

  // ... other methods
}
```

Include proper error mapping: 
- 401 → UnauthorizedException
- 404 → NotFoundException  
- ConnectionTimeout → NetworkException
```

---

### Prompt 1.2: Fix Laravel API Middleware Issue (302 Bug)

**Copy-paste this prompt:**

```
Our Laravel API is returning HTTP 302 redirects when it should return JSON responses.

Problem: POST /api/jobs with valid bearer token returns 302 redirect HTML instead of 201 created response.

File to check: portfoliophhadmin/routes/api.php

The issue is likely that:
1. The /api/jobs route is using web middleware instead of api middleware
2. OR CSRF verification is not excluded for API routes
3. OR the route is missing API middleware entirely

Please:
1. Show me the current routes/api.php structure (just the job routes section)
2. Ensure ALL /api/* routes have middleware('api') and middleware('auth:sanctum')
3. Check that web middleware (CSRF, session) is NOT applied to /api routes
4. Ensure ApiResource routes are properly defined with correct HTTP methods

The correct pattern should be:
```php
Route::middleware(['api', 'auth:sanctum'])->group(function () {
    Route::post('/jobs', [JobController::class, 'store']);
    Route::put('/jobs/{job}', [JobController::class, 'update']);
});
```

NOT using web middleware like:
```php
// WRONG - this causes 302 redirects
Route::middleware('web')->group(function () {
    Route::post('/jobs', [...]);
});
```

Fix the routing and verify CSRF is excluded for /api/* in Middleware/VerifyCsrfToken.php
```

---

### Prompt 1.3: Connect LoginScreen to Real Backend

**Copy-paste this prompt:**

```
I have a LoginScreen in lib/presentation/screens/auth/login_screen.dart that currently doesn't call the backend.

I need to:
1. Call ApiService.login(email, password) when user submits form
2. Store the returned token in flutter_secure_storage with key 'auth_token'
3. Store the user data in AuthProvider
4. Navigate to /dashboard on success
5. Show error toast on failure

Current flow: User → Form → Button → Need to add API call

The login button currently just navigates directly. Instead it should:
```dart
// Pseudo-code
onPressed: () async {
  try {
    showLoading();
    final response = await ApiService().login(email, password);
    await secureStorage.write(key: 'auth_token', value: response['token']);
    authProvider.setUser(response['user']);
    if(mounted) context.go('/dashboard');
  } catch (e) {
    showErrorToast(e.message);
  } finally {
    hideLoading();
  }
}
```

Generate the complete updated LoginScreen with:
- ApiService integration
- flutter_secure_storage usage
- Error handling with ToastService
- Loading state management
- Proper async/await handling
```

---

### Prompt 1.4: Implement Token Storage & Injection

**Copy-paste this prompt:**

```
I need Flutter to:
1. Store authentication token securely after login
2. Include bearer token in ALL API requests
3. Handle token expiration/refresh

Current state: ApiService exists but doesn't inject auth headers

Requirements:
1. Use flutter_secure_storage to save token with key 'auth_token'
2. Add Dio interceptor to inject "Authorization: Bearer {token}" header in all requests
3. Handle 401 responses by clearing token and redirecting to /login
4. Store token in AuthProvider for state access

Generate:
1. Updated ApiService with interceptor that:
   - Reads token from secure storage
   - Injects in Authorization header
   - Handles 401 responses

2. Updated AuthProvider methods:
   - saveToken(String token)
   - getToken() → String?
   - clearToken() and logout flow

3. Integration in main.dart to restore session on app start

The interceptor pattern should look like:
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get token from storage
    // Add to headers
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear token, redirect to login
    }
    handler.next(err);
  }
}
```
```

---

## PRIORITY 2: STABILIZE (2-3 hours)

### Prompt 2.1: Implement Local SeekerJobListProvider Error Handling

**Copy-paste this prompt:**

```
I have lib/features/seeker/providers/seeker_job_list_provider.dart that fetches jobs but needs better error handling.

Current issues:
1. Errors are caught but not displayed to users
2. No pagination support
3. No retry mechanism
4. No loading state distinction between initial load and pagination

Enhance the provider with:
1. Loading states: 
   - isLoading (initial load)
   - isPaginationLoading (loading next page)
2. Error state: 
   - error: String?
   - hasError: bool
3. Pagination:
   - currentPage: int
   - totalPages: int
   - loadMore() method
4. Retry mechanism:
   - retry() method after error

Expected structure:
```dart
class SeekerJobListProvider extends ChangeNotifier {
  List<SeekerJobModel> jobs = [];
  bool isLoading = false;
  bool isPaginationLoading = false;
  String? error;
  int currentPage = 1;
  int totalPages = 1;

  Future<void> fetchJobs({int page = 1}) async {
    // Set isLoading/isPaginationLoading
    try {
      final response = await apiService.getJobs(page: page, limit: 10);
      jobs = response['data'];
      totalPages = response['total_pages'];
      currentPage = page;
      error = null;
    } catch (e) {
      error = e.toString();
      // Keep existing data visible
    }
    notifyListeners();
  }

  void loadMore() async {
    if (currentPage < totalPages && !isPaginationLoading) {
      isPaginationLoading = true;
      notifyListeners();
      try {
        final response = await apiService.getJobs(page: currentPage + 1, limit: 10);
        jobs.addAll(response['data']);
        currentPage++;
      } catch (e) {
        error = e.toString();
      }
      isPaginationLoading = false;
      notifyListeners();
    }
  }
}
```

Generate the complete enhanced provider.
```

---

### Prompt 2.2: Create DatabaseService Implementation for SQLite

**Copy-paste this prompt:**

```
I have lib/data/services/database_service.dart that's currently a stub. 

I need to implement SQLite for offline data storage (optional for web, critical for mobile).

Implement:
1. Initialize SQLite using sqflite package (already in pubspec)
2. Create schema for tables:
   - users (id, email, name, role, created_at)
   - jobs (id, title, description, location, salary_min, salary_max, recruiter_id)
   - applications (id, job_id, user_id, status, cover_letter, created_at)
   - saved_jobs (job_id, user_id, created_at)

3. CRUD methods for each table:
   - insert(T model)
   - getById(int id)
   - getAll()
   - update(T model)
   - delete(int id)

4. Singleton pattern (factory constructor)

5. Initialize on app startup

Structure:
```dart
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late Database _db;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    final path = join(await getDatabasesPath(), 'portfolioph.db');
    _db = await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Create tables
  }
}
```

Generate complete implementation with:
- Proper migrations
- Foreign key constraints
- Indexes for performance
- Error handling
```

---

### Prompt 2.3: Add Email Notifications Backend

**Copy-paste this prompt:**

```
Laravel backend needs email notifications. Currently Mailpit is configured but not used.

Implement email notifications for:
1. Application received:
   - Recipient: Recruiter (when someone applies to their job)
   - Subject: "New Application: {job_title}"
   - Content: Show applicant name, job, date

2. Application status changed:
   - Recipient: Job seeker (when their application status updates)
   - Subject: "Your application to {job_title}: {status}"
   - Content: Application status, next steps

3. Job posted:
   - Recipient: Subscribed users (future feature)
   - Subject: "New job matching your skills: {job_title}"

Implementation steps:
1. Create Mailable classes:
   - ApplicationReceived
   - ApplicationStatusChanged
   - JobPosted

2. Update controllers to dispatch notifications:
   - ApplicationController@store → send ApplicationReceived
   - ApplicationController@updateStatus → send ApplicationStatusChanged

3. Use Mail facade with to/cc/subject/markdown methods

4. Create email templates in resources/mails/

5. Configure MAIL_MAILER=smtp in .env

Pattern:
```php
// In controller
Mail::to($recruiter->email)->send(new ApplicationReceived($application));

// In Mailable class
class ApplicationReceived extends Mailable {
    public function build() {
        return $this->markdown('emails.application-received');
    }
}
```

Generate:
- All 3 Mailable classes
- Updated controllers
- Email Blade templates (3)
- Database seeders to set up email config
```

---

## PRIORITY 3: COMPLETE MVP (4-6 hours)

### Prompt 3.1: Create Missing Portfolio Screens

**Copy-paste this prompt:**

```
Portfolio feature is missing all UI screens. Create:

1. PortfolioDetailScreen - Display user's portfolio
   - Show user info, projects, skills, education, experience
   - Edit button for profile owner
   - Share portfolio URL button

2. PortfolioEditScreen - Edit portfolio sections
   - Dropdown menu: Edit projects, skills, education, experience
   - Form validation
   - Save/cancel buttons

3. ProjectDetailScreen - Show individual project
   - Title, description, technologies, links, dates
   - Edit/delete buttons for owner

4. EditProjectScreen - Add/edit projects
   - Form with: title, description, technologies (tags), url, github_link, start_date, end_date
   - Image upload preview
   - Validation

Each screen:
- Should use Consumer<PortfolioProvider> to access state
- Should have proper error handling
- Should navigate correctly back
- Should support read-only mode (viewing others' portfolios)

Pattern:
```dart
class PortfolioDetailScreen extends StatelessWidget {
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return SkeletonLoader();
        if (provider.hasError) return ErrorStateWidget();
        
        return ListView(
          children: [
            // Portfolio sections
          ],
        );
      },
    );
  }
}
```

Generate all 4 screens with:
- Full UI implementation
- State management integration
- Form validation
- Proper error handling
```

---

### Prompt 3.2: Implement Application Status Management UI

**Copy-paste this prompt:**

```
Job seekers need to see their applications and status. Create:

1. SeekerApplicationsScreen:
   - List of user's applications
   - Show: job title, company, status (badge), date applied
   - Filter by status (pending, accepted, rejected, shortlisted)
   - Pull-to-refresh

2. ApplicationDetailScreen:
   - Full application details
   - Job info
   - Cover letter text
   - Current status
   - Status history timeline
   - Can only be accessed by applicant

Integrate with SeekerApplicationProvider that:
- Fetches from GET /api/applications
- Handles pagination
- Filters locally
- Provides retry mechanism

Each application shows status with color-coded badge:
- pending: gray
- accepted: green
- rejected: red
- shortlisted: blue

Pattern:
```dart
class SeekerApplicationsScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SeekerApplicationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return SkeletonLoader();
        
        return RefreshIndicator(
          onRefresh: () => provider.fetchApplications(),
          child: ListView.builder(
            itemCount: provider.applications.length,
            itemBuilder: (context, index) {
              final app = provider.applications[index];
              return ApplicationListTile(application: app);
            },
          ),
        );
      },
    );
  }
}
```

Generate both screens with complete implementation.
```

---

### Prompt 3.3: Add File Upload Support

**Copy-paste this prompt:**

```
Job applications need resume uploads. Add file upload support:

1. Backend (Laravel):
   - Add resume_url field to applications table
   - Migration to add column
   - FileController to handle uploads
   - Endpoint: POST /api/applications/{id}/upload-resume
   - Validation: PDF only, max 5MB
   - Store in storage/uploads/resumes/

2. Frontend (Flutter):
   - Add file picker (already have image_picker)
   - Show file preview before upload
   - Upload progress indicator
   - Error handling for large files

Backend structure:
```php
Route::post('/applications/{application}/upload-resume', [FileController::class, 'uploadResume'])->middleware('auth:sanctum');

// In FileController
public function uploadResume(Request $request, Application $application) {
    // Validate ownership
    // Validate file
    // Store file
    // Update application.resume_url
}
```

Flutter:
```dart
// In ApplicationDetailScreen
Future<void> uploadResume() async {
    final file = await FilePicker.platform.pickFiles();
    if (file != null) {
        final progress = await apiService.uploadResume(applicationId, file);
        // Show upload progress
    }
}
```

Generate:
- Laravel migration
- FileController with uploadResume method
- Flutter file picker widget
- Upload progress UI
- Error handling
```

---

## PRIORITY 4: TESTING & DEPLOYMENT

### Prompt 4.1: Architecture for Integration Tests

**Copy-paste this prompt:**

```
Create integration test architecture for Flutter + Laravel.

Test scenarios:
1. User Registration → Login → Create Job → Apply → Check Status
2. Error handling: network failure, invalid credentials, authorization
3. Pagination: fetch 50+ jobs, verify pagination works
4. Concurrent operations: multiple users applying simultaneously

Create:
1. Test setup/teardown:
   - Seed test database with known data
   - Create test users (recruiter, seeker, admin)
   - Clear database after tests

2. Helper functions:
   - registerUser(email, password, role)
   - loginUser(email, password)
   - createJob(recruiter, jobData)
   - applyForJob(seeker, jobId)

3. Test cases in test/integration/:
   - auth_flow_test.dart
   - job_lifecycle_test.dart
   - applications_test.dart

Pattern:
```dart
void main() {
  group('Integration Tests', () {
    setUpAll(() async {
      await database.seed();
    });

    tearDownAll(() async {
      await database.clear();
    });

    test('Complete user journey', () async {
      final user = await apiService.register(...);
      expect(user, isNotNull);
      
      final token = await apiService.login(...);
      expect(token, isNotEmpty);
    });
  });
}
```

Generate test structure with:
- Setup/teardown logic
- Helper functions
- 5-10 integration test cases
- Mocking strategies
```

---

### Prompt 4.2: Docker Deployment Configuration

**Copy-paste this prompt:**

```
Improve Docker setup for production readiness:

1. Multi-stage build for Laravel:
   - Build stage: Composer install, compile
   - Runtime stage: Optimized image, minimal size

2. Production env variables in Docker:
   - APP_ENV=production
   - Debug mode off
   - Proper security headers

3. Database migrations on startup:
   - Run migrations automatically
   - Seed admin user
   - Health check endpoint

4. Nginx configuration:
   - Port 80 (http public)
   - Port 443 (https when ready)
   - Static file caching
   - Gzip compression

5. Docker Compose enhancements:
   - Redis cache layer
   - Health checks for all services
   - Proper volume management
   - Network isolation

Generate:
- Updated docker/Dockerfile (multi-stage)
- Updated docker-compose.yml (production-ready)
- nginx.conf optimization
- .env.production template
```

---

## QUICK COPY-PASTE COMMANDS

### To run the app locally:

```bash
# Terminal 1: Start Laravel backend
cd portfoliophhadmin
php artisan serve --host=127.0.0.1 --port=8000

# Terminal 2: Run Flutter web app
flutter run -d chrome

# Terminal 3: Monitor Laravel logs
tail -f storage/logs/laravel.log
```

### To test integration:

```bash
# Flutter integration tests
flutter test integration_test/auth_flow_test.dart

# Laravel Feature tests
php artisan test tests/Feature/

# Laravel Unit tests
php artisan test tests/Unit/
```

---

## VALIDATION CHECKLIST AFTER FIXES

After implementing each prompt, verify:

- [ ] No TODO comments in critical files
- [ ] API calls return JSON (not HTML redirects)
- [ ] Errors show useful messages (not stack traces)
- [ ] Loading states prevent multiple submissions
- [ ] Token persists across app restarts
- [ ] Tests pass (run full test suite)
- [ ] No console errors/warnings
- [ ] Manual testing: register → login → create job → apply

---

**Last Updated:** April 5, 2026 | For all issues, start with Priority 1 prompts
