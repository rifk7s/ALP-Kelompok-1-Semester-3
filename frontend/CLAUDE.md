# CLAUDE.md - Frontend (Flutter)

> See also: [Root CLAUDE.md](../CLAUDE.md) | [Detailed Patterns](docs/flutter-patterns.md)

---

## Architecture

```
features/feature_name/
├── model/        # Data models
├── service/      # API calls (use apiClient)
├── repository/   # Data layer + caching
├── bloc/         # State management
└── view/
    ├── screens/  # Full pages
    └── widgets/  # Components
```

**Layering:** `Screen → BLoC → Repository → Service → API`

**IMPORTANT:** BLoCs call repositories, NEVER services directly.

---

## Critical Rules

### Network - ALWAYS use apiClient

```dart
// ✅ Correct
import 'package:frontend/core/network/api_client.dart';
final response = await apiClient.get('/products');

// ❌ Wrong - No timeout, no IP fallback
final response = await http.get(Uri.parse(url));
```

### Colors - NEVER hardcode

```dart
// ✅ Correct
import 'package:frontend/core/theme/theme.dart';
color: AppColors.primary

// ❌ Wrong
color: Color(0xFF8A6B4F)
color: Colors.red
```

### AppBar with primary background

```dart
AppBar(
  backgroundColor: AppColors.primary,
  foregroundColor: AppColors.white,  // REQUIRED!
)
```

### Navigation - Use GoRouter

```dart
// ✅ Correct
context.pop();
context.push('/path');

// ❌ Wrong
Navigator.pop(context);
```

### Async navigation - Check mounted

```dart
await someAsyncOperation();
if (!context.mounted) return;  // REQUIRED!
context.pop();
```

### StatefulWidget Lifecycle

```dart
// ALWAYS dispose controllers
@override
void dispose() {
  _controller.removeListener(_onChange);  // Remove listeners first
  _controller.dispose();                   // Then dispose
  _timer?.cancel();                        // Cancel timers
  _subscription?.cancel();                 // Cancel streams
  super.dispose();
}

// ALWAYS check mounted after await
final data = await api.fetch();
if (!mounted) return;
setState(() => _data = data);
```

> See [docs/flutter-patterns.md#statefulwidget-lifecycle](docs/flutter-patterns.md#statefulwidget-lifecycle) for detailed patterns.

### SnackBars - Use helper

```dart
// ✅ Correct - throttled
SnackBarHelper.showSuccess(context, 'Done');
SnackBarHelper.showError(context, 'Failed');

// ❌ Wrong - no throttle
ScaffoldMessenger.of(context).showSnackBar(...);
```

### Loading delays - Use constants

```dart
// ✅ Correct
await Future.delayed(LoadingDelayConstants.standardList);

// ❌ Wrong
await Future.delayed(Duration(milliseconds: 500));
```

---

## Dependency Injection

```dart
import 'package:frontend/core/di/injection.dart';

// Access anywhere
final repo = sl<ProductRepository>();

// In widgets
context.read<CartBloc>().add(CartLoadRequested());
context.watch<HomeBloc>().state;
```

| Scope | Contents |
|-------|----------|
| **Base** | AuthBloc, ProductRepository, CategoryRepository |
| **Authenticated** | CartBloc, HomeBloc, CartRepository, OrderRepository |

---

## BLoC Naming

| Type | Pattern | Example |
|------|---------|---------|
| **Events** | `FeatureActionRequested` | `CartItemAdded`, `ProductLoadRequested` |
| **States** | `FeatureStatus` | `ProductInitial`, `ProductLoading`, `ProductSuccess` |
| **Files** | `feature_bloc.dart`, `feature_event.dart`, `feature_state.dart` |

---

## Caching

```dart
import 'package:frontend/core/cache/cache_helper.dart';

// Get/Set
final cached = CacheHelper.get<List>('products');
CacheHelper.set('products', data, CacheDurations.productList);

// Invalidate on mutations
CacheHelper.invalidatePattern('product');
```

| Duration | TTL | Use For |
|----------|-----|---------|
| `categories` | 10 min | Category list |
| `productList` | 3 min | Product lists |
| `productDetail` | 2 min | Single product |
| `petaniList` | 5 min | Petani lists |

---

## UI Helpers

| Helper | Purpose |
|--------|---------|
| `SnackBarHelper` | Throttled snackbars |
| `RetryableContent` | Error state with retry button |
| `ShakeWidget` | Form validation animation |
| `EmptyStateWidget` | Empty state display |
| `DialogManager` | Prevent duplicate dialogs |

---

## Loading Widgets

| Widget | Context |
|--------|---------|
| `AppSmallLoadingIndicator` | Buttons |
| `AppLoadingIndicator` | Page content |
| `AppFullScreenLoading` | Overlays |

---

## Common Imports

```dart
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/utils/ui_helpers.dart';
import 'package:frontend/core/utils/currency_formatter.dart';
import 'package:frontend/core/widgets/loading_widgets.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/cache/cache_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
```

---

## Quick Reference

| Task | Use |
|------|-----|
| HTTP calls | `apiClient.get/post/put/delete()` |
| Colors | `AppColors.*` |
| Navigate | `context.push/pop/go()` |
| SnackBar | `SnackBarHelper.show*()` |
| Loading delay | `LoadingDelayConstants.*` |
| Cache | `CacheHelper.get/set/invalidate*()` |
| Currency | `CurrencyFormatter.rupiah(amount)` |

---

> **Need detailed examples?** See [docs/flutter-patterns.md](docs/flutter-patterns.md)
