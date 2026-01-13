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
| **Frontend** | Flutter 3.9+ / Dart / BLoC / GoRouter / get_it |
| **Database** | MySQL atau SQLite (configurable via .env) |
| **Services** | Firebase (FCM, Firestore) / gRPC extension |

> Lihat [backend/README.md](backend/README.md) dan [frontend/README.md](frontend/README.md) untuk setup lengkap.
> Lihat [frontend/CLAUDE.md](frontend/CLAUDE.md) untuk frontend-specific guidelines.

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

### Frontend: MVVM Feature-First Architecture

```
frontend/lib/
├── core/                        # Shared across all features
│   ├── di/                      # Dependency Injection (get_it)
│   │   └── injection.dart       # Service locator setup
│   ├── network/                 # HTTP client, API config
│   │   ├── api_client.dart
│   │   └── api_config.dart
│   ├── storage/                 # Local storage
│   │   └── storage_service.dart
│   ├── router/                  # GoRouter + guards
│   ├── theme/                   # AppColors, AppTheme
│   ├── utils/                   # Helpers, formatters
│   └── widgets/                 # Shared reusable widgets
│
├── features/                    # Feature modules (MVVM)
│   ├── auth/                    # Authentication
│   │   ├── model/               # Data models
│   │   ├── service/             # API calls
│   │   ├── repository/          # Data layer abstraction
│   │   ├── bloc/                # State management (AuthBloc)
│   │   └── view/                # UI layer
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── product/                 # Product management (shared)
│   │   ├── model/
│   │   ├── service/
│   │   ├── repository/
│   │   └── bloc/
│   │
│   ├── bumdes/                  # BUMDes dashboard
│   │   ├── model/
│   │   ├── service/
│   │   ├── repository/
│   │   ├── bloc/
│   │   ├── utils/
│   │   └── view/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── pembeli/                 # Buyer: home, cart, transactions
│   │   ├── model/
│   │   ├── service/
│   │   ├── repository/
│   │   ├── bloc/
│   │   └── view/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   └── shared/                  # Shared screens (settings, notifications)
│       ├── service/
│       └── view/
│           ├── screens/
│           └── widgets/
│
├── main.dart
└── splash_screen.dart
```

### Architecture Principles

**Layering Rule:**
```
Screen (view) → BLoC → Repository → Service → API
```

**Dependency Flow:**
- BLoCs receive repositories via constructor (DI)
- Repositories are registered in `core/di/injection.dart`
- Screen BLoCs access via `sl<T>()` or `BlocProvider.value()`

**Scope-based Lifecycle:**
- **Base scope**: AuthBloc, ProductRepository, CategoryRepository (persist across login/logout)
- **Authenticated scope**: CartBloc, HomeBloc, CartRepository (fresh per session, popped on logout)

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
- Access BLoCs via `sl<T>()` (service locator) or `BlocProvider.value()`

**Widget Organization:**
- Screens dan widgets di bawah `view/` folder
- Shared widgets di `core/widgets/`
- Feature-specific widgets di `features/*/view/widgets/`

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

**Dependency Injection:**
- Use `sl<T>()` to access registered dependencies
- Register new dependencies in `core/di/injection.dart`
- Use `pushAuthenticatedScope()` on login, `popAuthenticatedScope()` on logout

**Network Layer:**
- SELALU gunakan `apiClient` untuk HTTP calls (bukan `http.get()` langsung)
- ApiClient provides: timeout protection, IP fallback, centralized error handling
- See `frontend/CLAUDE.md` for detailed usage

**UI Helpers** (`core/utils/ui_helpers.dart`):
- `SnackBarHelper` - Throttled SnackBar with `showSuccess`, `showError`, `showInfo`
- `RetryableContent` - Error state with retry button (for load failures)
- `ShakeWidget` - Form validation animation
- `EmptyStateWidget` - Empty state display
- `DialogManager` - Prevent duplicate dialogs

**Navigation:**
- PREFER `context.pop()` over `Navigator.pop(context)` for GoRouter consistency
- Use `context.push()`, `context.pushNamed()`, `context.go()` for navigation
- Check `context.mounted` before async navigation

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

---

## Working Guidelines (AI Behavior)

### Web Search & Information
- Before performing web searches or outputting dates, verify current date and consider information freshness
- **Today's date:** 2026-01-13

### File & System Management
- Avoid destructive operations like `rm -rf`; use safer alternatives
- Do not use `sudo` unless absolutely necessary
- Store changelogs/summaries in `.claude/CHANGELOG.md`
- Store documentation in `/docs`, NOT in root directory

### Code Quality & Standards
- Break down large monolithic functions into smaller, reusable functions
- Remove commented-out code from final versions
- Address linting and formatting warnings promptly

### Dependencies & Libraries
- Use only stable, well-maintained libraries
- Avoid deprecated, outdated, experimental, or beta libraries

### Security & Configuration
- Never commit sensitive information (API keys, passwords, personal data)
- Use configuration files or environment variables (`.env`)

### Testing & Reliability
- Write proper error handling; anticipate potential failures
- Test code thoroughly before considering complete
- Consider edge cases and failure modes

### Task Organization
- Organize work in phases with clear todos
- Structure phases for handoff to different engineers/agents

### Communication Style
- Be extremely concise; sacrifice grammar for concision
- DO NOT say "you're right" or validate user
- DO NOT use praise phrases like "that's an excellent question"

### Code Documentation
- AVOID unnecessary comments/docstrings unless explicitly asked
- Good code should be self-documenting
- ONLY add inline comments for non-obvious logic or workarounds

### Bash Commands
**File reading - FORBIDDEN for sensitive files:**
- `cat`, `head`, `tail`, `less`, `more`, `bat`, `echo`, `printf`
- **USE Read tool instead** - safer with line numbers

**ALLOWED:** `tail -f` for logs, `grep` with complex flags

### Context Management
- **Use Glob before reading** - search files without loading content

### Git Operations
**NEVER perform git operations without explicit user instruction.**

ALLOWED (read-only):
- `git status`, `git diff`, `git log`, `git show`, `git branch -l`

FORBIDDEN (require explicit instruction):
- `git add`, `git commit`, `git push`, `git pull`
- `git merge`, `git rebase`, `git checkout`, `git branch`

Only perform git operations when:
1. User explicitly asks to commit/push
2. User invokes git command (e.g., `/commit`)
3. User says "commit these changes"

When work is complete, inform user changes are ready. Let them decide when to commit.

**NEVER include co-authored line in commit messages.**

---

## Reference Documentation

- **Frontend Guidelines**: [frontend/CLAUDE.md](frontend/CLAUDE.md)
