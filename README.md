### Hastvani (Flutter)

Modern Flutter application built with Material 3, responsive layout, and a modular presentation layer.

### Features
- Responsive UI using `sizer` and adaptive widgets
- Authentication flow and onboarding
- Lesson player, assessments, progress tracking
- Offline-friendly storage via `shared_preferences`
- Charts and data viz with `fl_chart`

### Tech stack
- Flutter 3.x, Dart 3.x
- Android Gradle Plugin 8.7, Kotlin 2.1
- Key packages: `flutter_svg`, `google_fonts`, `cached_network_image`, `connectivity_plus`, `fluttertoast`, `permission_handler`, `video_player`, `fl_chart`

### Prerequisites
- Flutter SDK installed and added to PATH (`flutter --version`)
- Android Studio + Android SDKs installed
- Windows: enable Developer Mode for symlink support (required by plugins)
  - Open Settings → For Developers → turn on Developer Mode

### Project layout
```
lib/
  core/
  presentation/
  routes/
  theme/
  widgets/
assets/
  images/
android/
```

### Setup
```bash
flutter pub get
```

### Running (debug)
```bash
flutter run
```

### Build APK (release)
```bash
flutter build apk --release
# Output: android/app/build/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Release signing (Android)
1) Generate a keystore (one-time):
```bash
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
2) Create `android/key.properties`:
```
storeFile=../keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=upload
keyPassword=YOUR_KEY_PASSWORD
```
3) Configure signing in `android/app/build.gradle.kts` (release `signingConfig`).
4) Rebuild: `flutter build apk --release` or `flutter build appbundle --release`.

### Environment
The app reads configuration from `env.json` if present for environment-specific values.

### Troubleshooting
- Developer Mode not enabled (Windows): enable it to allow plugin symlinks.
- Gradle cache errors: stop Gradle and clear caches
```powershell
./gradlew --stop
flutter clean
flutter pub get
```
- SDK/NDK mismatch: ensure `compileSdk = 36` and `ndkVersion = "27.0.12077973"` in `android/app/build.gradle.kts`.
- Kotlin mismatch: `android/settings.gradle.kts` uses `org.jetbrains.kotlin.android` 2.1.0.

### License
Proprietary – internal use only unless licensed otherwise.
