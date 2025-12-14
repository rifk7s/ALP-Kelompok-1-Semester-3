
# Frontend (Flutter)

[⬅ Back to root README](../README.md) · [Backend README ➜](../backend/README.md)

Flutter mobile app for the project.

## Prerequisites

- [![Flutter](https://img.shields.io/badge/Flutter-3.9.2%2B-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
- [![Dart](https://img.shields.io/badge/Dart-3.9.2%2B-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
- [![Firebase](https://img.shields.io/badge/Firebase-Core%20%2B%20Auth%20%2B%20Firestore-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)

> [!IMPORTANT]
> This app is configured for **Android** and **iOS** only.
> `lib/firebase_options.dart` throws an error on web/desktop (macOS/Windows/Linux) unless you re-run FlutterFire configuration.

## Setup

From the repository root:

```bash
cd frontend
flutter pub get
```

### iOS (macOS only)

> [!NOTE]
> You need CocoaPods installed (e.g. `pod --version` should work).

```bash
cd ios
pod install
cd ..
```

> [!NOTE]
> The iOS project uses CocoaPods and targets iOS 15.6.

## Firebase configuration (required)

This repo intentionally ignores Firebase config files and `.env` because they contain secrets.

### 1) Add Firebase native config files

- Android: put `google-services.json` at `android/app/google-services.json`
- iOS: put `GoogleService-Info.plist` at `ios/Runner/GoogleService-Info.plist`

> [!TIP]
> You can download these from Firebase Console → Project settings → Your apps.

Optional (regenerate with FlutterFire CLI):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 2) Create `.env` (required)

The app loads environment variables at startup via `flutter_dotenv`.
Create `frontend/.env` with the following keys:

```dotenv
# Android
FIREBASE_API_KEY=
FIREBASE_APP_ID=

# iOS
FIREBASE_IOS_API_KEY=
FIREBASE_IOS_APP_ID=
FIREBASE_IOS_BUNDLE_ID=

# Shared
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_PROJECT_ID=
FIREBASE_DATABASE_URL=
FIREBASE_STORAGE_BUCKET=
```

> [!WARNING]
> If any of these are missing/empty you will get a runtime error like: `Missing env: FIREBASE_API_KEY`.

> [!NOTE]
> Values can be found inside `google-services.json` and `GoogleService-Info.plist` (or via Firebase Console). Even if you don't use Realtime Database, `FIREBASE_DATABASE_URL` must be set because it is required by the current initialization code.

## Backend API configuration (required)

This app calls the Laravel API using a hard-coded base URL in `lib/core/services/api_config.dart`.

Current behavior:

- Android emulator uses `http://10.0.2.2:8000/api`
- iOS/physical device uses `http://10.1.50.240:8000/api` (you likely need to change this)

> [!IMPORTANT]
> If you're running the backend on your machine, start it with network binding:
> ```bash
> cd ../backend
> php artisan serve --host=0.0.0.0 --port=8000
> ```
> Then update the `_iosDeviceUrl` and `_iosDeviceBase` constants in `lib/core/services/api_config.dart` to your machine's LAN IP.

> [!TIP]
> For iOS Simulator (on macOS), you can usually point it to `http://127.0.0.1:8000/api`.

Backend setup docs are in [../backend/README.md](../backend/README.md).

## Running

Start the app:

```bash
cd frontend
flutter run
```

Run on a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

> [!IMPORTANT]
> Make sure the backend is reachable from your emulator/device or you will see timeouts (e.g. `Connection timeout - Backend not reachable`).

## Build

Android APK:

```bash
cd frontend
flutter build apk
```

iOS (requires macOS + Xcode):

```bash
cd frontend
flutter build ios
```

## Troubleshooting

### Firebase file missing

- Android error mentions `google-services.json` → make sure `android/app/google-services.json` exists
- iOS build fails due to missing plist → make sure `ios/Runner/GoogleService-Info.plist` exists

### Missing env variables

If you see `Missing env: ...`, confirm `frontend/.env` exists and contains all required keys.

### Can't connect to backend

- Android emulator: keep `10.0.2.2` (it maps to your host machine)
- Physical devices: use your machine's LAN IP and run backend with `--host=0.0.0.0`
