# Job Platform Mobile App (Flutter)

Complete mobile application for the Job Platform built with **Flutter 3.10+**, **Provider** state management, and **GoRouter** for navigation.

## 📱 Project Structure

```
mobile-jobs/
├── lib/
│   ├── main.dart               # App entry point
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart # Configuration
│   │   └── services/
│   │       └── api_service.dart # HTTP client
│   ├── data/
│   │   ├── models/             # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── job_model.dart
│   │   │   └── application_model.dart
│   │   └── repositories/       # Data layer
│   │       ├── auth_repository.dart
│   │       └── job_repository.dart
│   ├── presentation/
│   │   ├── providers/          # State management
│   │   │   ├── auth_provider.dart
│   │   │   ├── job_provider.dart
│   │   │   └── app_providers.dart
│   │   ├── screens/            # UI screens
│   │   │   ├── auth/
│   │   │   ├── jobs/
│   │   │   └── applications/
│   │   └── widgets/            # Reusable widgets
│   ├── routes/
│   │   └── app_router.dart     # Navigation routes
│   └── utils/                  # Utility functions
├── pubspec.yaml               # Dependencies
└── README.md
```

## 🚀 Quick Start

### Prerequisites
- Flutter 3.10.0 or higher
- Dart 3.0.0 or higher
- Android Studio / Xcode (for emulators)
- VS Code or Android Studio

### Installation Steps

```bash
# 1. Navigate to mobile directory
cd mobile-jobs

# 2. Get dependencies
flutter pub get

# 3. Configure API endpoint (optional)
# Edit lib/core/config/app_config.dart if needed

# 4. Run on emulator/device
flutter run

# 5. Or build for specific platform
flutter run -d chrome          # Web
flutter run -d android         # Android emulator
flutter run -i                 # iOS simulator
```

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| provider | 6.1.0 | State management (ChangeNotifier) |
| go_router | 14.3.0 | Navigation & routing |
| dio | 5.3.1 | HTTP client |
| flutter_secure_storage | 9.0.0 | Secure token storage |
| intl | 0.19.0 | Internationalization |
| uuid | 4.0.0 | Generate unique IDs |
| connectivity_plus | 5.0.0 | Network connectivity |

## 🔐 Authentication

### Login Flow

```dart
// 1. User enters credentials
// 2. AuthProvider.login() called
// 3. ApiService sends request to backend
// 4. Token received and stored securely
// 5. User redirected to /jobs
```

**Test Credentials:**
```
Email: seeker@jobplatform.test
Password: password
```

### Token Management

Tokens are stored securely using `flutter_secure_storage`:
- Automatically saved on login/register
- Auto-injected into all API headers as Bearer token
- Cleared on logout
- 401 responses trigger logout

## 📋 Data Flow

### Job Browsing Flow

```
JobListScreen
    ↓
JobProvider.fetchJobs()
    ↓
JobRepository.getJobs()
    ↓
ApiService.getJobs()
    ↓
Backend API (GET /api/jobs)
    ↓
Response → Models → Provider → UI
```

### Application Flow

```
JobDetailScreen (Apply button)
    ↓
JobProvider.applyJob()
    ↓
JobRepository.applyJob()
    ↓
ApiService.applyJob()
    ↓
Backend API (POST /api/jobs/{id}/apply)
    ↓
Success → Add to myApplications → Redirect
```

## 🎨 UI Screens

### Implemented
- **LoginScreen** - Full authentication UI
- **SplashScreen** - App startup screen
- **Router & Navigation** - Complete routing setup

### To Implement
- **RegisterScreen** - New user registration with role selection
- **RoleSelectionScreen** - Choose job seeker or recruiter
- **JobListScreen** - Browse approved jobs with filters
- **JobDetailScreen** - View full job details and apply
- **PostJobScreen** - Create new job listing (recruiter)
- **MyApplicationsScreen** - Track all user applications

Each screen follows the same pattern:
1. Consume providers from context
2. Build UI widgets
3. Handle user actions
4. Update state via providers
5. Navigate on success/error

## 🛠️ State Management (Provider)

### AuthProvider
```dart
// Check if logged in
if (authProvider.isAuthenticated) {
  // Show main app
}

// Get user info
authProvider.user?.name
authProvider.user?.role

// Perform actions
authProvider.login(email, password)
authProvider.logout()
```

### JobProvider
```dart
// Get list of jobs
provider.jobs

// Load more
provider.fetchJobs(page: 2)

// Apply for job
provider.applyJob(jobId: 1)

// View my applications
provider.myApplications
```

## 🔐 Security

- ✅ Tokens stored in secure storage (encrypted)
- ✅ Bearer token auto-injected into headers
- ✅ 401 errors trigger logout
- ✅ Password fields hidden by default
- ✅ Input validation on all forms
- ✅ HTTPS recommended for production

## 🧪 Testing

### Manual Testing Steps

```bash
# 1. Start backend
cd backend && php artisan serve

# 2. Update API_URL if needed
# Edit lib/core/config/app_config.dart

# 3. Run Flutter app
flutter run

# 4. Test login
# Use: seeker@jobplatform.test / password

# 5. Test job browsing
# Should see list of approved jobs

# 6. Test application
# Click on a job and apply

# 7. Check my applications
# Navigate to my applications screen
```

### Test Users

**Job Seeker (Pre-approved):**
```
Email: seeker@jobplatform.test
Password: password
Role: job_seeker
Status: Approved
```

**Recruiter (Approved):**
```
Email: recruiter@jobplatform.test
Password: password
Role: recruiter
Status: Approved
```

**Admin:**
```
Email: admin@jobplatform.test
Password: password
Role: admin
```

## 📱 Building for Platforms

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (Google Play)
flutter build appbundle --release

# Output: build/app/outputs/
```

### iOS

```bash
# Build IPA
flutter build ios --release

# Archive
cd ios && xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner -configuration Release -archivePath \
  build/Runner.xcarchive archive
```

### Web

```bash
# Build web
flutter build web --release

# Run locally
flutter run -d web

# Output: build/web/
```

## 🐛 Troubleshooting

### App won't connect to API
- Check API URL in `lib/core/config/app_config.dart`
- Ensure backend is running (`php artisan serve`)
- Try IP address instead of localhost on physical devices
- Check device firewall/network connectivity

### Login doesn't work
- Verify credentials are correct
- Check backend logs for SQL errors
- Ensure database migrations have run
- Verify CORS configuration

### Token not persisting
- Clear app cache: `flutter clean && flutter pub get`
- Check secure storage permissions (Android/iOS manifest)
- Verify token is being saved in ApiService

### Build errors
```bash
# Clean rebuild
flutter clean
flutter pub get
flutter pub run build_runner build
flutter run
```

### Slow Performance
- Build in release mode: `flutter run --release`
- Profile app: `flutter run --profile`
- Check for unnecessary rebuilds in DevTools

## 📊 API Endpoints Used

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | /api/auth/login | User login |
| POST | /api/auth/register | New user signup |
| POST | /api/auth/logout | User logout |
| GET | /api/auth/me | Get current user |
| GET | /api/jobs | List jobs (paginated) |
| GET | /api/jobs/{id} | Job details |
| POST | /api/jobs/{id}/apply | Apply for job |
| GET | /api/my-applications | User's applications |
| POST | /api/applications/{id}/withdraw | Withdraw application |

## 🎯 Development Workflow

### Add New Screen

```dart
// 1. Create file in lib/presentation/screens/
class NewScreen extends StatefulWidget {
  const NewScreen({Key? key}) : super(key: key);

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  @override
  Widget build(BuildContext context) {
    // Build UI
  }
}

// 2. Add route in lib/routes/app_router.dart
GoRoute(
  path: '/new-screen',
  builder: (context, state) => const NewScreen(),
),

// 3. Navigate
context.go('/new-screen');
```

### Add API Endpoint

```dart
// 1. Add method to ApiService (core/services/api_service.dart)
Future<Map<String, dynamic>> newEndpoint() async {
  final response = await _dio.get('/new-endpoint');
  return response.data;
}

// 2. Add method to Repository (data/repositories/job_repository.dart)
Future<Model> newMethod() async {
  final response = await _apiService.newEndpoint();
  return Model.fromJson(response);
}

// 3. Add method to Provider (presentation/providers/app_provider.dart)
Future<void> newAction() async {
  final result = await _repository.newMethod();
  // Update state
  notifyListeners();
}

// 4. Use in Screen
Consumer<Provider>(
  builder: (context, provider, child) {
    // Use provider.value
  },
)
```

## 📚 Documentation

- [JOB_PLATFORM_MASTER_GUIDE.md](../../JOB_PLATFORM_MASTER_GUIDE.md) - System design
- [PHASE_0_FLUTTER_SETUP.md](../../PHASE_0_FLUTTER_SETUP.md) - Detailed implementation
- [COMPLETE_SETUP_GUIDE.md](../../COMPLETE_SETUP_GUIDE.md) - Setup instructions
- [Flutter Docs](https://flutter.dev)
- [Provider Package](https://pub.dev/packages/provider)

## 🚀 Production Checklist

- [ ] Update API URL to production server
- [ ] Configure Firebase Crashlytics (optional)
- [ ] Setup proper error logging
- [ ] Enable code obfuscation
- [ ] Test on real devices
- [ ] Setup CI/CD pipeline
- [ ] Configure analytics
- [ ] Security audit
- [ ] Performance profiling
- [ ] Store release signing keys securely

### Commands

```bash
# Production build (Android)
flutter build apk --release --split-per-abi

# Production build (iOS)
flutter build ios --release

# Web deployment
flutter build web --release
# Deploy build/web/ to hosting service
```

## 📞 Support

- Flutter: https://flutter.dev
- Provider: https://pub.dev/packages/provider
- GoRouter: https://pub.dev/packages/go_router
- Dio: https://pub.dev/packages/dio

---

**Built with ❤️ for the Job Platform**
