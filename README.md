# ALP Kelompok 1 Semester 3 
A full-stack mobile application built with Flutter (frontend) and Laravel (backend).

## Prerequisites

### Backend

- [![PHP Version](https://img.shields.io/badge/PHP-8.2%2B-777BB4?style=flat-square&logo=php&logoColor=white)](https://www.php.net/)
- [![Composer](https://img.shields.io/badge/Composer-latest-885630?style=flat-square&logo=composer&logoColor=white)](https://getcomposer.org)
- [![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?style=flat-square&logo=node.js&logoColor=white)](https://nodejs.org)
- [![Laravel](https://img.shields.io/badge/Laravel-12.x-FF2D20?style=flat-square&logo=laravel&logoColor=white)](https://laravel.com)

### Frontend

- [![Flutter](https://img.shields.io/badge/Flutter-3.9.2%2B-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
- [![Dart](https://img.shields.io/badge/Dart-3.9.2%2B-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)

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

Run database migrations to create the database schema:

```bash
php artisan migrate
```

> [!NOTE]
> The default database is SQLite. The database file will be automatically created in `database/database.sqlite`.

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
> The default database is SQLite. If you encounter connection issues, ensure the database file exists.

**Solution:** Create the database file and run migrations

```bash
cd backend
touch database/database.sqlite
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

**Problem:** Application fails to start due to column/table conflicts

**Solution:** Drop the existing database and restart the application

**Steps:**
1. Delete the database file
2. Recreate the database schema with migrations

```bash
cd backend
rm database/database.sqlite
touch database/database.sqlite
php artisan migrate
```

> [!CAUTION]
> The database will be automatically recreated with the updated schema, but all previous data will be lost.

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
