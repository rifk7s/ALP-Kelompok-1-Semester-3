# ALP Kelompok 1 Semester 3 
A full-stack mobile application built with Flutter (frontend) and Laravel (backend).

## Docs

- Backend setup: [backend/README.md](backend/README.md)
- Frontend setup: [frontend/README.md](frontend/README.md)

## Secrets / Ignored Files

Some required config files are intentionally **not committed** (see `.gitignore`).

- Backend Firebase service account JSON: follow [backend/README.md](backend/README.md)
- Frontend Firebase files + env: follow [frontend/README.md](frontend/README.md)

## Prerequisites

### Backend

- [![PHP Version](https://img.shields.io/badge/PHP-8.2%2B-777BB4?style=flat-square&logo=php&logoColor=white)](https://www.php.net/)
- [![Composer](https://img.shields.io/badge/Composer-latest-885630?style=flat-square&logo=composer&logoColor=white)](https://getcomposer.org)
- [![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?style=flat-square&logo=node.js&logoColor=white)](https://nodejs.org)
- [![Laravel](https://img.shields.io/badge/Laravel-12.x-FF2D20?style=flat-square&logo=laravel&logoColor=white)](https://laravel.com)
- [![Firebase](https://img.shields.io/badge/Firebase-Admin%20SDK-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com/docs/admin/setup)
- [![Firestore](https://img.shields.io/badge/Firestore-Google%20Cloud-4285F4?style=flat-square&logo=googlecloud&logoColor=white)](https://cloud.google.com/firestore)
- ![gRPC](https://img.shields.io/badge/PHP%20ext-gRPC-required?style=flat-square)

### Frontend

- [![Flutter](https://img.shields.io/badge/Flutter-3.9.2%2B-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
- [![Dart](https://img.shields.io/badge/Dart-3.9.2%2B-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
- [![Firebase](https://img.shields.io/badge/Firebase-Core%20%2B%20Auth%20%2B%20Firestore-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/rifk7s/ALP-Kelompok-1-Semester-3.git
cd ALP-Kelompok-1-Semester-3
```

### Backend Setup

Navigate to the backend directory:

```bash
cd backend
```

Install PHP dependencies using Composer:

```bash
composer install
```

Install Node.js dependencies:

```bash
npm install
```

Create environment file and generate application key:

```bash
cp .env.example .env
php artisan key:generate
```

> [!IMPORTANT]
> Firestore requires the PHP `grpc` extension, and Firebase requires a service-account JSON.
> Follow the full backend guide: [backend/README.md](backend/README.md).

Run migrations / seeders by following: [backend/README.md](backend/README.md).

Return to the root directory:

```bash
cd ..
```

> [!TIP]
> `cd ..` navigates back to the parent directory.

### Frontend Setup

Navigate to the frontend directory:

```bash
cd frontend
```

Install Flutter dependencies:

```bash
flutter pub get
```

> [!IMPORTANT]
> The frontend requires Firebase config + environment variables (they are intentionally gitignored).
> Follow the full frontend guide: [frontend/README.md](frontend/README.md).

Return to the root directory:

```bash
cd ..
```

### Running the Application

#### Backend Server

Start the Laravel backend API server:

```bash
cd backend
php artisan serve
```

The API will be available at `http://127.0.0.1:8000`.

> [!IMPORTANT]
> For testing on iOS Simulator or Android Emulator, run the server with network binding:
> ```bash
> php artisan serve --host=0.0.0.0 --port=8000
> ```
> This allows mobile devices/emulators to connect to your local backend via your machine's IP address.

#### Frontend App

Open a new terminal and start the Flutter app:

```bash
cd frontend
flutter run
```

> [!IMPORTANT]
> Make sure the backend server is running before starting the Flutter app.

## Project Structure

```
.
├── backend/                 # Laravel backend API
│   ├── app/                # Application code
│   ├── database/          # Migrations and seeders
│   ├── routes/            # API routes
│   └── .env.example       # Environment configuration template
│
└── frontend/              # Flutter mobile app
    ├── lib/              # Dart application code
    ├── android/          # Android platform files
    ├── ios/              # iOS platform files
    └── pubspec.yaml      # Flutter dependencies
```

## Additional Commands

### Backend

Run tests:
```bash
cd backend
php artisan test
```

Run all development services (server, queue, logs, and Vite):
```bash
cd backend
composer run dev
```

> [!NOTE]
> `composer run dev` starts multiple services concurrently including the API server, queue worker, logs, and Vite for asset compilation. For simple API-only development, `php artisan serve` is sufficient.

### Frontend

Run on specific device:
```bash
cd frontend
flutter run -d <device-id>
```

Build APK for Android:
```bash
cd frontend
flutter build apk
```

## Troubleshooting

> [!WARNING]
> Before making any database changes, ensure you have backed up important data. Dropping the database will permanently delete all existing records.

### Backend Issues

#### Database Connection Error

> [!NOTE]
> This backend works with **SQLite** or **MySQL**. Pick whichever you prefer and configure it in `backend/.env`.

**If using SQLite (common on macOS):**

```bash
cd backend
touch database/database.sqlite
php artisan migrate
```

**If using MySQL (common on Windows):**

- Ensure your `.env` has `DB_CONNECTION=mysql` and correct `DB_HOST/DB_PORT/DB_DATABASE/DB_USERNAME/DB_PASSWORD`
- Create the database in MySQL (name must match `DB_DATABASE`)
- Then run:

```bash
cd backend
php artisan migrate
```

#### Permission Errors

**Problem:** Application fails due to permission issues in storage directories

**Solution:** Fix storage permissions

```bash
cd backend
chmod -R 775 storage bootstrap/cache
```

#### Database Schema Conflicts

If your schema/migrations get out of sync, the safest project-specific guidance depends on whether you’re using SQLite or MySQL.

Follow the backend docs for the recommended reset steps: [backend/README.md](backend/README.md).

### Frontend Issues

#### Flutter Not Found

**Problem:** Flutter commands not recognized

**Solution:** Verify Flutter installation

```bash
flutter doctor
```

> [!TIP]
> Run `flutter doctor` to diagnose any issues with your Flutter installation and follow the suggested fixes.

#### Build Failed

**Problem:** Build errors or dependency issues

**Solution:** Clean and rebuild the project

```bash
cd frontend
flutter clean
flutter pub get
```

#### Firebase Config Missing

If you see errors related to Firebase initialization, confirm you have created/added:

- `frontend/.env`
- `frontend/android/app/google-services.json`
- `frontend/ios/Runner/GoogleService-Info.plist`

Setup details + required keys are in [frontend/README.md](frontend/README.md).

#### Can't Connect To Backend API

If the app times out calling the API, check the base URLs in [frontend/lib/core/services/api_config.dart](frontend/lib/core/services/api_config.dart).

- Android emulator should use `http://10.0.2.2:8000/api`
- iOS simulator / physical devices must use a reachable host IP

Also ensure the backend is running with network binding:

```bash
cd backend
php artisan serve --host=0.0.0.0 --port=8000
```
