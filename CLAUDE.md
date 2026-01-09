# CLAUDE.md

## Project Overview

Aplikasi marketplace BUMDes (Badan Usaha Milik Desa) yang menghubungkan petani dengan pembeli.

**Roles:**
- **BUMDes**: Mengelola produk, petani contributor, dan transaksi
- **Pembeli**: Melihat produk, checkout, dan tracking pesanan

## Tech Stack

| Layer | Stack |
|-------|-------|
| **Backend** | PHP 8.2+ / Laravel 12 / Sanctum / Pest |
| **Frontend** | Flutter 3.9+ / Dart / BLoC / GoRouter |
| **Database** | MySQL atau SQLite (configurable via .env) |
| **Services** | Firebase (FCM, Firestore) / gRPC extension |

> Lihat [backend/README.md](backend/README.md) dan [frontend/README.md](frontend/README.md) untuk setup lengkap.

## Running the Project

**Backend:**
```bash
cd backend
php artisan serve --host=0.0.0.0 --port=8000
```

**Frontend:**
```bash
cd frontend
flutter run
# Select device when prompted
```

---

## Architecture

### Frontend: Feature-First Architecture

```
frontend/lib/
├── core/                    # Shared across all features
│   ├── auth/bloc/           # Global auth state (AuthBloc)
│   ├── router/              # GoRouter + guards
│   ├── services/            # API services, storage
│   ├── theme/               # AppColors, AppTheme
│   ├── utils/               # Helpers, formatters
│   └── widgets/             # Reusable widgets
│
├── features/                # Feature modules
│   ├── auth/                # Login, register
│   │   ├── screens/
│   │   └── widgets/
│   ├── bumdes/              # BUMDes dashboard, products, petani
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── bloc/
│   │   └── utils/
│   ├── pembeli/             # Buyer: home, cart, transactions
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── bloc/
│   ├── product/             # Product management (shared)
│   │   ├── bloc/
│   │   ├── cubit/
│   │   └── repository/
│   └── shared/              # Shared screens (settings, notifications)
│       ├── screens/
│       └── widgets/
│
├── main.dart
└── splash_screen.dart
```

### Backend: Laravel Standard Structure

```
backend/
├── app/
│   ├── Http/Controllers/    # API controllers
│   ├── Models/              # Eloquent models
│   └── Services/            # Business logic
├── database/
│   ├── migrations/          # MySQL + SQLite compatible
│   └── seeders/
├── routes/
│   └── api.php              # API routes
└── storage/app/private/     # Firebase credentials (gitignored)
```

---

## Coding Standards

### Flutter/Dart

**Naming:**
- Files: `snake_case.dart` (e.g., `upload_screen.dart`)
- Classes: `PascalCase` (e.g., `UploadProdukScreen`)
- Variables/methods: `camelCase` (e.g., `selectedKategori`)
- Constants: `camelCase` (e.g., `AppColors.primary`)

**State Management:**
- Gunakan **BLoC** untuk complex state dengan events
- Gunakan **Cubit** untuk simple state tanpa events
- State classes: `FeatureState`, `FeatureLoading`, `FeatureSuccess`, `FeatureFailure`

**Widgets:**
- Extract reusable widgets ke folder `widgets/`
- Prefix dengan nama feature jika spesifik (e.g., `BumdesSectionCard`)
- Shared widgets di `core/widgets/`

**Theme & Colors:**
- SELALU gunakan `AppColors` dari `core/theme/theme.dart`
- JANGAN hardcode warna (e.g., `Color(0xFF...)` atau `Colors.red`)
- AppBar dengan `AppColors.primary` HARUS pakai `foregroundColor: AppColors.white`

```dart
// Correct
AppBar(
  backgroundColor: AppColors.primary,
  foregroundColor: AppColors.white,
)

// Wrong
AppBar(
  backgroundColor: Color(0xFF8A6B4F),
)
```

### Laravel/PHP

- Ikuti conventions dari `backend/CLAUDE.md` (Laravel Boost)
- Form Requests untuk validasi
- Eloquent Resources untuk API responses
- Pest untuk testing

---

## Commit Convention

Format: Conventional commit dengan bullet points per file.

```
<type>(<scope>): <short description>

- <file>:
  - <change 1>
  - <change 2>
```

**Types:**

| Type | Keterangan |
|------|------------|
| `feat` | Fitur baru |
| `fix` | Bug fix |
| `refactor` | Refactoring tanpa ubah behavior |
| `style` | Formatting, styling |
| `docs` | Dokumentasi |
| `test` | Testing |
| `chore` | Maintenance, dependencies |

**Contoh:**

```
feat(auth): add JWT support

- auth.js:
  - add token generation
  - verify middleware

- login_screen.dart:
  - integrate token storage
```

```
fix(ui): resolve AppBar color conflicts

- upload_screen.dart:
  - add foregroundColor to AppBar
  - remove duplicate asterisks from labels

- common_widgets.dart:
  - change label color to textPrimary
```

---

## API Documentation

API documentation otomatis di-generate menggunakan [Scramble](https://scramble.dedoc.co/).

**Akses:** `http://127.0.0.1:8000/docs/api#/` (saat backend running)

### Key Packages

| Package | Fungsi |
|---------|--------|
| `laravel/sanctum` | API authentication (token-based) |
| `dedoc/scramble` | Auto-generated OpenAPI docs |
| `kreait/laravel-firebase` | Firebase Admin SDK |
| `google/cloud-firestore` | Firestore database |

### Development Tools

| Package | Command |
|---------|---------|
| `laravel/pint` | `vendor/bin/pint` - Code formatting |
| `pestphp/pest` | `php artisan test` - Testing |
| `laravel/pail` | `php artisan pail` - Real-time logs |

### Useful Scripts

```bash
composer run dev      # Server + queue + logs + vite
composer run setup    # Full setup (install, migrate, build)
composer run test     # Run tests
```
