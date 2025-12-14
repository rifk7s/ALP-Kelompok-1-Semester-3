
# Backend (Laravel)

[⬅ Back to root README](../README.md) · [Frontend README ➜](../frontend/README.md)

Laravel 12 backend API for the project. This backend uses **Firebase (Admin SDK)** and **Google Cloud Firestore**.

## Prerequisites

- [![PHP Version](https://img.shields.io/badge/PHP-8.2%2B-777BB4?style=flat-square&logo=php&logoColor=white)](https://www.php.net/)
- [![Composer](https://img.shields.io/badge/Composer-latest-885630?style=flat-square&logo=composer&logoColor=white)](https://getcomposer.org)
- [![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?style=flat-square&logo=node.js&logoColor=white)](https://nodejs.org)
- [![Laravel](https://img.shields.io/badge/Laravel-12.x-FF2D20?style=flat-square&logo=laravel&logoColor=white)](https://laravel.com)
- [![Firebase](https://img.shields.io/badge/Firebase-Admin%20SDK-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com/docs/admin/setup)
- [![Firestore](https://img.shields.io/badge/Firestore-Google%20Cloud-4285F4?style=flat-square&logo=googlecloud&logoColor=white)](https://cloud.google.com/firestore)

> [!IMPORTANT]
> **PHP gRPC extension is required** for Firestore (`google/cloud-firestore`). See the **PHP gRPC extension** section below.

## Setup (local development)

From the repository root:

```bash
cd backend
```

### 1) Install dependencies

```bash
composer install
npm install
```

### 2) Create `.env`

```bash
cp .env.example .env
php artisan key:generate
```

### 3) Configure database (SQLite recommended)

Laravel defaults to SQLite when `DB_CONNECTION` is not set, but this repo’s `.env.example` ships with MySQL enabled.

**Option A — SQLite (recommended for quick local setup)**

1) Update `.env`:

```dotenv
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite
```

2) Create the SQLite file:

```bash
touch database/database.sqlite
```

**Option B — MySQL**

Set your MySQL credentials in `.env` (keep `DB_CONNECTION=mysql`) and ensure the database exists.

### 4) Configure Firebase credentials

This backend expects a Firebase **service account JSON** file and reads it using:

```dotenv
FIREBASE_CREDENTIALS=storage/app/private/your-firebase-adminsdk.json
FIREBASE_DB_URL=https://your-project-id-default-rtdb.firebasedatabase.app/
FIREBASE_PROJECT_ID=your-project-id
```

> [!IMPORTANT]
> `FIREBASE_CREDENTIALS` is treated as a path **relative to the Laravel base path**.

Suggested local layout:

```bash
mkdir -p storage/app/private
# put your JSON here (do NOT commit it)
```

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force storage/app/private | Out-Null
# put your JSON here (do NOT commit it)
```

Windows (CMD):

```bat
mkdir storage\app\private
REM put your JSON here (do NOT commit it)
```

### 5) Migrate

```bash
php artisan migrate
```

### 6) Seed (important order)

Some seeders depend on other tables/data. Recommended order:

```bash
php artisan db:seed --class=CategorySeeder
php artisan db:seed --class=HppPriceSeeder
php artisan db:seed --class=PetaniDataSeeder
php artisan db:seed --class=ProductSeeder
php artisan db:seed --class=OrderSeeder
```

> [!NOTE]
> `HppPriceSeeder` depends on categories (so it must run after `CategorySeeder`).

> [!NOTE]
> `OrderSeeder` requires products. If products are missing it will print: “No products found. Please seed products first.”

### 7) Storage symlink

```bash
php artisan storage:link
```

### 8) Run the backend

API server only:

```bash
php artisan serve
```

Run server + queue + logs + Vite (recommended for active development):

```bash
composer run dev
```

> [!TIP]
> There is also a convenience script: `composer run setup` (installs deps, generates key, runs migrations, installs/builds Vite).

## PHP gRPC extension (required for Firestore)

Firestore uses gRPC under the hood via the PHP extension `grpc`.

### Verify

```bash
php -m | grep -i grpc
```

If you don’t see `grpc`, install and enable it (steps vary per OS).

### macOS

Try PECL first:

```bash
pecl install grpc
```

If PECL cannot install a compatible binary, build from the PECL source tarball (common on macOS):

> [!NOTE]
> You may need Xcode Command Line Tools and common build tooling (e.g. `phpize`, `autoconf`, `make`).

```bash
pecl download grpc
tar -xzf grpc-*.tgz
cd grpc-*
phpize
./configure
make
make install
```

Enable it in the PHP config you’re using (CLI and/or FPM):

```ini
extension=grpc.so
```

> [!NOTE]
> The exact `php.ini` location depends on your PHP installation (Homebrew PHP, MAMP, XAMPP, etc.).

### Linux

Install build tools + PECL, then install the extension:

> [!TIP]
> On Debian/Ubuntu you typically need: `php-dev`, `php-pear`, `gcc`, `make`, `autoconf`.

```bash
sudo pecl install grpc
```

Enable it in your `php.ini`:

```ini
extension=grpc.so
```

Restart your PHP service (e.g. `php-fpm`, Apache) if needed.

### Windows

1) Download the matching `php_grpc.dll` from `https://pecl.php.net/package/grpc`
2) Put it into your PHP `ext` directory
3) Enable it in `php.ini`:

```ini
extension=php_grpc.dll
```

> [!IMPORTANT]
> Make sure the DLL matches your PHP version, architecture (x64), and thread-safety (TS/NTS).

## Troubleshooting

### Firestore errors mentioning gRPC

If you get errors like “Class \Grpc\ChannelCredentials not found” or “grpc extension is required”, confirm the extension is enabled for the PHP you’re running:

```bash
php -v
php --ini
php -m | grep -i grpc
```

### Firebase credentials file not found

If you see errors about missing credentials, verify:

- `.env` points to the correct path in `FIREBASE_CREDENTIALS`
- the JSON file exists at that path
- the path is relative to the backend base path (project `backend/`)
