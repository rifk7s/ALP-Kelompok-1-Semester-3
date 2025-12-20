# ALP Kelompok 1 Semester 3 
A full-stack mobile application built with Flutter (frontend) and Laravel (backend).

## Team Members

| No | Name |
|----|------|
| 1  | Abel El Zachary 
| 2  | Britney Glory Chen 
| 3  | Keihan Pradika Muzaki 
| 4  | Michael Vergo 
| 5  | M. Rifki Paranrengi 
| 6  | Vivian Wijaya 

## Documentation

> [!NOTE]
> Full setup guides are available for both backend and frontend components.

- **[Backend Setup](backend/README.md)** - Laravel API, Firebase, database configuration
- **[Frontend Setup](frontend/README.md)** - Flutter app, Firebase configuration, API connection

> [!IMPORTANT]
> This project requires Firebase configuration for both backend and frontend. Config files are intentionally **not committed** to Git.
> 
> See individual README files above for detailed setup instructions.

## Tech Stack

### Backend
- [![PHP](https://img.shields.io/badge/PHP-8.2%2B-777BB4?style=flat&labelColor=777BB4&logo=php&logoColor=white&color=6c757d)](https://www.php.net/)
- [![Composer](https://img.shields.io/badge/Composer-latest-885630?style=flat&labelColor=885630&logo=composer&logoColor=white&color=6c757d)](https://getcomposer.org)
- [![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?style=flat&labelColor=339933&logo=node.js&logoColor=white&color=6c757d)](https://nodejs.org)
- [![Laravel](https://img.shields.io/badge/Laravel-12.x-FF2D20?style=flat&labelColor=FF2D20&logo=laravel&logoColor=white&color=6c757d)](https://laravel.com)
- [![Firebase Admin SDK](https://img.shields.io/badge/Firebase-Admin%20SDK-FFCA28?style=flat&labelColor=FFCA28&logo=firebase&logoColor=black&color=6c757d)](https://firebase.google.com/docs/admin/setup)
- [![Firestore](https://img.shields.io/badge/Firestore-Google%20Cloud-4285F4?style=flat&labelColor=4285F4&logo=googlecloud&logoColor=white&color=6c757d)](https://cloud.google.com/firestore)
- [![gRPC](https://img.shields.io/badge/gRPC-ext-2E8B57?style=flat&labelColor=2E8B57&logo=grpc&logoColor=white&color=6c757d)](https://pecl.php.net/package/gRPC/)

### Frontend
- [![Flutter](https://img.shields.io/badge/Flutter-3.9.2%2B-02569B?style=flat&labelColor=02569B&logo=flutter&logoColor=white&color=6c757d)](https://flutter.dev)
- [![Dart](https://img.shields.io/badge/Dart-3.9.2%2B-0175C2?style=flat&labelColor=0175C2&logo=dart&logoColor=white&color=6c757d)](https://dart.dev)
- [![Firebase](https://img.shields.io/badge/Firebase-Core%20%2B%20Auth%20%2B%20Firestore-FFCA28?style=flat&labelColor=FFCA28&logo=firebase&logoColor=black&color=6c757d)](https://firebase.google.com)

### Database
- [![SQLite](https://img.shields.io/badge/SQLite-07405E?style=flat&logo=sqlite&logoColor=white)](https://www.sqlite.org/)
- [![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat&logo=mysql&logoColor=white)](https://www.mysql.com/)

> [!TIP]
> Choose either SQLite or MySQL - configurable in `.env`

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/rifk7s/ALP-Kelompok-1-Semester-3.git
cd ALP-Kelompok-1-Semester-3
```

### 2. Backend Setup

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
```

> [!NOTE]
> **Next steps:** See [backend/README.md](backend/README.md) for:
> - PHP gRPC extension installation
> - Firebase credentials setup
> - Database configuration
> - Running migrations & seeders

### 3. Frontend Setup

```bash
cd frontend
flutter pub get
```

> [!NOTE]
> **Next steps:** See [frontend/README.md](frontend/README.md) for:
> - Firebase config files (`google-services.json`, `GoogleService-Info.plist`)
> - Environment variables (`.env` file)
> - API endpoint configuration

### 4. Run the Application

**Terminal 1 - Backend:**
```bash
cd backend
php artisan serve --host=0.0.0.0 --port=8000
```

**Terminal 2 - Frontend:**
```bash
cd frontend
flutter run
```

> [!TIP]
> Use `--host=0.0.0.0` for backend so mobile emulators/devices can connect.

## Project Structure

```
.
├── backend/           # Laravel API + Firebase Admin SDK
│   ├── app/          # Controllers, Models, Services
│   ├── database/     # Migrations, Seeders
│   └── routes/       # API routes
│
└── frontend/         # Flutter mobile app
    ├── lib/         # Dart source code
    ├── android/     # Android platform files
    └── ios/         # iOS platform files
```

## Common Issues

> [!WARNING]
> Common configuration issues and their solutions are listed below. Address these before seeking additional help.

### Backend not reachable from mobile

> [!IMPORTANT]
> Run backend with network binding to allow mobile devices/emulators to connect.

```bash
cd backend
php artisan serve --host=0.0.0.0 --port=8000
```

Update IP in `frontend/lib/core/services/api_config.dart` if needed.

### Firebase configuration missing

> [!CAUTION]
> The application will not function without proper Firebase configuration for both backend and frontend.

Both frontend and backend need Firebase setup:
- **Backend:** Service account JSON → [backend/README.md](backend/README.md#4-configure-firebase-credentials)
- **Frontend:** Config files + `.env` → [frontend/README.md](frontend/README.md#firebase-configuration-required)

### Database errors

> [!TIP]
> Most database errors can be resolved by ensuring the database file/instance exists and credentials are correct.

**SQLite:**
```bash
cd backend
touch database/database.sqlite
php artisan migrate
```

**MySQL:** Ensure database exists and `.env` credentials are correct.

---

> [!NOTE]
> For detailed troubleshooting:
> - [Backend troubleshooting](backend/README.md#troubleshooting)
> - [Frontend troubleshooting](frontend/README.md#troubleshooting)
