# Flutter Production Build & Obfuscation Quick Reference

## 🎯 ONE-COMMAND BUILDS

### Android App Bundle (For Google Play Store) - RECOMMENDED
```bash
cd /path/to/portfolioph

flutter build appbundle \
  --flavor production \
  -t lib/main_production.dart \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

# Output: build/app/outputs/bundle/productionRelease/app-production-release.aab
# Size: ~18-25 MB (will be smaller on Play Store after compression)
# Upload to: Google Play Console
```

### Android APK (For Testing or Direct Installation)
```bash
flutter build apk \
  --flavor production \
  -t lib/main_production.dart \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

# Output: build/app/outputs/flutter-app.apk
# Size: ~35-50 MB
# Install: adb install build/app/outputs/flutter-app.apk
```

### iOS App (Requires macOS)
```bash
flutter build ios \
  --flavor production \
  -t lib/main_production.dart \
  --release \
  --obfuscate \
  --split-debug-info=build/app/symbols

# Then archive via Xcode:
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme production \
  -configuration Release -archivePath build/Runner.xcarchive archive
```

### Web (If applicable)
```bash
flutter build web \
  --flavor production \
  -t lib/main_production.dart \
  --release

# Output: build/web/
# Deploy to: Firebase Hosting, Netlify, or your server
```

---

## 🔒 Obfuscation Explained

### What Does `--obfuscate` Do?

1. **Minifies Dart code**: Removes whitespace, comments, shortens variable names
2. **Renames symbols**: `loginUser()` becomes `a()` 
3. **Strips debug info**: Removes line numbers and stack traces
4. **Enables optimization**: Enables tree shaking and dead code elimination

### Example

**Before obfuscation:**
```dart
class AuthService {
  Future<bool> loginUser(String email, String password) {
    debugPrint('Attempting login: $email');
    final response = await api.post('/login', body: {
      'email': email,
      'password': password,
    });
    return response.success;
  }
}
```

**After obfuscation:**
```
class a {
  Future<bool> b(String c, String d) {
    final e = f.g('/h', body: {
      'i': c,
      'j': d,
    });
    return e.k;
  }
}
```

### `--split-debug-info` Explained

- **Normal release**: No debug info (can't trace crashes)
- **With `--split-debug-info`**: Debug symbols stored separately
- **Location**: `build/app/outputs/symbols/`
- **Usage**: Upload to Sentry/Crashlytics for readable crash logs

```
# Structure created:
build/app/outputs/symbols/
├── app-production-release.aab.symbols
├── vm_isolate_snapshot.bin.symbols
├── isolate_snapshot.bin.symbols
└── app.so.symbols
```

---

## 📦 Build Size Optimization

### Check APK/AAB Size

```bash
# Analyze APK
flutter build apk --release --analyze-size
# Shows breakdown by package

# Produce size report
dart pub global activate devtools
flutter build appbundle --release --analyze-size
```

### Target Sizes (After Optimization)

| Target | Recommended Max | Current |
|--------|-----------------|---------|
| Android APK | 50 MB | TBD |
| Android AAB | 25 MB | TBD |
| iOS IPA | 30 MB | TBD |
| Web JS | 10 MB (gzipped) | TBD |

### Reduce Size If Exceeding:

1. **Remove unused dependencies:**
   ```bash
   flutter pub global deactivate
   flutter clean
   flutter pub get
   flutter analyze
   ```

2. **Enable aggressive tree shaking:**
   ```bash
   flutter build apk --split-per-abi
   # Creates separate APK for each CPU architecture
   ```

3. **Compress resources:**
   ```gradle
   // android/app/build.gradle
   android {
     release {
       shrinkResources true
       minifyEnabled true
     }
   }
   ```

---

## 🚀 Signing & Publishing

### Android - Sign for Play Store

```bash
# 1. Create keystore (first time only)
keytool -genkey -v -keystore ~/.android/release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias portfolioph-key

# 2. Create key.properties file
cat > android/key.properties << EOF
storeFile=/home/username/.android/release-key.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=portfolioph-key
keyPassword=YOUR_KEY_PASSWORD
EOF

# 3. Uncomment in android/app/build.gradle:
# signingConfigs {
#     release {
#         keyAlias keystoreProperties['keyAlias']
#         keyPassword keystoreProperties['keyPassword']
#         storeFile file(keystoreProperties['storeFile'])
#         storePassword keystoreProperties['storePassword']
#     }
# }
# buildTypes {
#     release {
#         signingConfig signingConfigs.release
#     }
# }

# 4. Build AAB (automatically signed)
flutter build appbundle --release --obfuscate

# 5. Upload to Play Console:
# https://play.google.com/console → Your app → Release → Production → Upload AAB
```

### iOS - Sign for App Store

```bash
# 1. Setup in Xcode (automatic)
# Xcode → Runner → Signing & Capabilities → Team selection

# 2. Build IPA
flutter build ios --release --obfuscate

# 3. Archive in Xcode
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner \
  -configuration Release -archivePath build/app.xcarchive archive

# 4Export for App Store
xcodebuild -exportArchive -archivePath build/app.xcarchive \
  -exportPath build/ios/ipa -exportOptionsPlist ExportOptions.plist

# 5. Upload via Xcode or Transporter
xcrun altool --upload-app --file "build/ios/ipa/PortfolioPH.ipa" \
  --type ios --username "your-apple-id@example.com" --password "app-specific-password"
```

---

## 🔍 Pre-Release Checklist

- [ ] **Build locally in release mode:**
  ```bash
  flutter build appbundle --release --obfuscate
  ```

- [ ] **Test with real devices** (not emulator):
  - Minimum Android 5.0 (API 21)
  - Minimum iOS 12.0

- [ ] **Verify obfuscation:**
  ```bash
  # Check symbols are removed
  strings build/app/outputs/flutter-app.apk | grep "debugPrint"
  # Should return: (empty)
  ```

- [ ] **Verify environment:**
  ```bash
  # Confirm using production API
  flutter run -t lib/main_production.dart --release
  # Login and test all features
  ```

- [ ] **Network conditions:**
  - Test on 3G
  - Test offline → online
  - Test with VPN

- [ ] **Crash reporting:**
  - Register with Sentry/Firebase
  - Verify debug symbols uploaded

- [ ] **Version bump:**
  ```yaml
  # pubspec.yaml
  version: 1.0.0+1  # Increment build number
  ```

---

## 📱 Platform-Specific Configurations

### Android Configuration (AndroidManifest.xml)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <!-- Min SDK: 21 (Android 5.0) -->
  <uses-sdk
    android:minSdkVersion="21"
    android:targetSdkVersion="34" />
  
  <!-- Internet permission (required) -->
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  
  <!-- File access (for resume upload) -->
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
  
  <application
    android:usesCleartextTraffic="false"
    android:hardwareAccelerated="true">
    <!-- Hardened: No cleartext (must use HTTPS) -->
  </application>
</manifest>
```

### iOS Configuration (Info.plist)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- Min iOS: 12.0 -->
  <key>MinimumOSVersion</key>
  <string>12.0</string>
  
  <!-- File access (for resume) -->
  <key>NSPhotoLibraryUsageDescription</key>
  <string>We need access to select resume files</string>
  
  <!-- Network security -->
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <!-- HTTPS only -->
  </dict>
</dict>
</plist>
```

---

## 🐛 Crash Reporting Setup (Optional but Recommended)

### Firebase Crashlytics

```bash
# Add to pubspec.yaml:
firebase_core: ^2.0.0
firebase_crashlytics: ^3.0.0

# Configure in main_production.dart:
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Capture Flutter errors
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };
  
  runApp(const App());
}
```

### Sentry (Alternative)

```bash
# Add to pubspec.yaml:
sentry_flutter: ^7.0.0

# Configure in main_production.dart:
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://your-key@sentry.io/project-id';
      options.environment = 'production';
    },
    appRunner: () => runApp(const App()),
  );
}
```

---

## ⚠️ Common Build Issues

### Issue: `gradle is not found`
```bash
# Solution:
flutter clean
flutter pub get
flutter packages get
cd android && ./gradlew clean && cd ..
flutter build apk --release
```

### Issue: `Obfuscation failed`
```bash
# Solution (disable for debugging):
flutter build apk --release
# Remove --obfuscate flag temporarily
```

### Issue: `Code size > 50MB`
```bash
# Solution:
flutter build apk --release --split-per-abi
# Creates: app-armeabi-v7a-release.apk, app-arm64-v8a-release.apk
# Users get appropriate version based on device
```

### Issue: `Certificate/Signing errors`
```bash
# Check keystore:
keytool -list -v -keystore ~/.android/release-key.jks

# Recreate if needed:
rm ~/.android/release-key.jks
keytool -genkey -v -keystore ~/.android/release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias production-key
```

---

## 📊 Success Metrics

After production deployment, monitor:

| Metric | Target | Check |
|--------|--------|-------|
| App startup time | < 2 seconds | Analytics dashboard |
| Crash rate | < 0.1% | Sentry/Firebase |
| API latency | < 500ms avg | Network logs |
| Download size | < 50MB | Play Store report |
| Daily active users | > baseline | Firebase dashboard |

---

**Ready to launch! 🚀**

Next steps:
1. Run: `flutter build appbundle --flavor production -t lib/main_production.dart --release --obfuscate`
2. Upload to Play Console/App Store
3. Set up crash reporting
4. Monitor in first 24 hours
5. Celebrate 🎉

