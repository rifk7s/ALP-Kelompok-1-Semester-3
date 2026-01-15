# CLAUDE.md - Frontend (Flutter)

> Lihat juga: [Root CLAUDE.md](../CLAUDE.md) untuk project-wide guidelines.

---

## Architecture Overview

### MVVM Feature-First Structure

```
features/feature_name/
├── model/               # Data models (optional - can use Map<String, dynamic>)
├── service/             # API calls
├── repository/          # Data layer abstraction
├── bloc/                # State management (BLoC/Cubit)
└── view/                # UI layer
    ├── screens/         # Full page widgets
    └── widgets/         # Reusable components
```

### Layering Rule

```
Screen (view) → BLoC → Repository → Service → API
```

**IMPORTANT:** BLoCs should NEVER call services directly. Always go through repositories.

---

## Dependency Injection (get_it)

### Service Locator Pattern

**Import:**
```dart
import 'package:frontend/core/di/injection.dart';
```

**Access dependencies anywhere:**
```dart
// Get registered instance
final authBloc = sl<AuthBloc>();
final productRepo = sl<ProductRepository>();

// In widgets (preferred - context-aware)
context.read<AuthBloc>();
context.watch<CartBloc>();
```

### Scope-based Lifecycle

**Base Scope** (persists across login/logout):
- AuthBloc, AuthRepository
- ProductRepository, CategoryRepository
- BumdesRepository, PetaniRepository

**Authenticated Scope** (fresh per session, popped on logout):
- CartBloc, HomeBloc, ProductDetailBloc
- CartRepository, OrderRepository, NotificationRepository

**Usage:**
```dart
// Setup (called once in main())
setupLocator();

// On login (automatic in AuthBloc)
pushAuthenticatedScope();

// On logout (automatic in AuthBloc)
await popAuthenticatedScope();
```

### Registering New Dependencies

**In `core/di/injection.dart`:**

```dart
void setupLocator() {
  // Base scope - persist across login/logout
  sl.registerLazySingleton<MyRepository>(() => MyRepository());
  sl.registerLazySingleton<MyBloc>(
    () => MyBloc(repository: sl<MyRepository>()),
  );

  // Factory - new instance each time (for screen-specific BLoCs)
  sl.registerFactory<ScreenBloc>(
    () => ScreenBloc(repository: sl<MyRepository>()),
  );
}

void pushAuthenticatedScope() {
  sl.pushNewScope(
    scopeName: 'authenticated',
    init: (getIt) {
      // User-specific dependencies
      getIt.registerLazySingleton<CartRepository>(() => CartRepository());
      getIt.registerLazySingleton<CartBloc>(
        () => CartBloc(repository: getIt<CartRepository>()),
      );
    },
  );
}
```

---

## State Management

### BLoC vs Cubit: Kapan Pakai Apa?

| Gunakan | Untuk | Contoh |
|---------|-------|--------|
| **BLoC** | Complex flows dengan multiple events | AuthBloc, CartBloc, ProductBloc |
| **Cubit** | Simple state tanpa event transformation | ProductEditingCubit |

### BLoC Pattern

**File Structure:**
```
features/feature_name/bloc/
├── feature_bloc.dart      # BLoC class
├── feature_event.dart     # Events
└── feature_state.dart     # States
```

**Event Naming:** `FeatureActionRequested`
```dart
// Correct
class ProductCreateRequested extends ProductEvent {}
class CartItemAdded extends CartEvent {}
class AuthLoginRequested extends AuthEvent {}

// Wrong
class CreateProduct extends ProductEvent {}  // Tidak pakai Requested
class AddCartItem extends CartEvent {}       // Verb di depan
```

**State Naming:** `FeatureStatus`
```dart
abstract class ProductState extends Equatable {}

class ProductInitial extends ProductState {}
class ProductLoading extends ProductState {}
class ProductSuccess extends ProductState {
  final Map<String, dynamic>? product;
}
class ProductFailure extends ProductState {
  final String error;
}
```

**State dengan Data (untuk editing):**
```dart
class ProductEditing extends ProductState {
  final List<Map<String, dynamic>> petaniContributors;
  final List<File> selectedImages;

  // SELALU implement copyWith untuk immutability
  ProductEditing copyWith({...}) {
    return ProductEditing(
      petaniContributors: petaniContributors ?? this.petaniContributors,
      ...
    );
  }
}
```

### Cubit Pattern

**Untuk simple state management tanpa events:**
```dart
class ProductEditingCubit extends Cubit<ProductEditing> {
  ProductEditingCubit() : super(const ProductEditing());

  void addContributor(Map<String, dynamic> contributor) {
    final updated = List<Map<String, dynamic>>.from(state.petaniContributors)
      ..add(contributor);
    emit(state.copyWith(petaniContributors: updated));
  }

  void removeContributor(int index) {
    final updated = List<Map<String, dynamic>>.from(state.petaniContributors);
    updated.removeAt(index);
    emit(state.copyWith(petaniContributors: updated));
  }
}
```

### BLoC Location

| Scope | Location | Contoh |
|-------|----------|--------|
| **Global (base scope)** | `features/auth/bloc/` | AuthBloc |
| **Scoped (auth scope)** | `features/*/bloc/` | CartBloc, HomeBloc |
| **Screen-specific** | Direct instantiation via factory | ProductBloc (upload/edit) |

---

## Network Layer (`core/network/`)

### ApiClient - Centralized HTTP Client

**SELALU gunakan `apiClient` untuk semua HTTP calls di services!**

```dart
import 'package:frontend/core/network/api_client.dart';

// Global singleton instance
final response = await apiClient.get('/products', token: token);
```

**Available Methods:**

| Method | Use For |
|--------|---------|
| `apiClient.get()` | GET requests |
| `apiClient.post()` | POST with JSON body |
| `apiClient.put()` | PUT with JSON body |
| `apiClient.patch()` | PATCH with JSON body |
| `apiClient.delete()` | DELETE requests |
| `apiClient.multipartPost()` | File uploads |

**Benefits:**
- **Timeout protection** - All requests have configurable timeout (default 2s connection, 10s receive)
- **IP fallback** - Automatically tries backup IPs on connection failure
- **Auto-reset** - Resets to primary IP before each request cycle
- **Centralized error handling** - Throws `ApiException` with helpful hints

**Example Service:**
```dart
class ProductService {
  static Future<List<dynamic>> getProducts() async {
    final response = await apiClient.get('/products/product');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load products');
  }
}
```

### JANGAN Gunakan http Langsung

```dart
// ❌ Wrong - No timeout, no IP fallback
final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/products'));

// ✅ Correct - Uses centralized client
final response = await apiClient.get('/products');
```

### ApiConfig - Network Configuration

```dart
import 'package:frontend/core/network/api_config.dart';

// Get current base URL
ApiConfig.baseUrl  // Returns platform-appropriate URL

// Get image URL from relative path
ApiConfig.getImageUrl('products/image.jpg')

// Connection settings
ApiConfig.connectionTimeout  // 2 seconds
ApiConfig.receiveTimeout     // 10 seconds
```

---

## Repository Pattern

### What is a Repository?

Repository abstracts the data source. BLoCs call repositories, not services.

**Benefits:**
- Centralized data logic
- Easier testing (can mock repositories)
- Single source of truth for data operations

### Example Repository

```dart
// features/product/repository/product_repository.dart
class ProductRepository {
  final ProductService _service = ProductService();

  Future<List<Map<String, dynamic>>> getProducts() async {
    return await _service.getProducts();
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    return await _service.getProduct(id);
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    return await _service.createProduct(data);
  }
}
```

### BLoC with Repository

```dart
// features/product/bloc/product_bloc.dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;

  ProductBloc({required ProductRepository repository})
      : _repository = repository,
        super(ProductInitial()) {
    on<ProductLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await _repository.getProducts();
      emit(ProductSuccess(products: products));
    } catch (e) {
      emit(ProductFailure(error: e.toString()));
    }
  }
}
```

**Register in DI:**
```dart
// core/di/injection.dart
sl.registerLazySingleton<ProductRepository>(() => ProductRepository());
sl.registerFactory<ProductBloc>(
  () => ProductBloc(repository: sl<ProductRepository>()),
);
```

**Use in screen:**
```dart
BlocProvider(
  create: (_) => sl<ProductBloc>()..add(ProductLoadRequested()),
  child: ...,
)
```

---

## Widget Patterns

### Widget Organization

```
features/feature_name/
└── view/
    ├── screens/           # Full page widgets
    │   └── feature_screen.dart
    └── widgets/           # Reusable components
        ├── feature_card.dart
        └── feature_list.dart

core/widgets/              # Shared across ALL features
├── loading_widgets.dart
└── app_spacing.dart
```

### Naming Convention

| Type | Pattern | Contoh |
|------|---------|--------|
| **Screen** | `FeatureScreen` | `UploadProdukScreen`, `CartScreen` |
| **Feature Widget** | `FeatureComponentName` | `BumdesSectionCard`, `PetaniContributorList` |
| **Core Widget** | `AppComponentName` | `AppLoadingIndicator`, `AppSmallLoadingIndicator` |

### BUMDes Widgets (Reusable)

**Form Widgets** (`features/bumdes/view/widgets/`):
```dart
// Section card dengan title
BumdesSectionCard(
  title: "Informasi Utama",
  child: Column(...),
)

// Input label dengan required indicator
BumdesInputLabel("Nama Produk", required: true)  // Renders: "Nama Produk *"

// Price field dengan auto-formatting
BumdesPriceField(
  controller: _hargaController,
  labelText: 'Harga per Kg *',
)

// Number field
BumdesNumberField(
  controller: _jumlahController,
  labelText: 'Jumlah Stok (kg) *',
)
```

### Loading Widgets (`core/widgets/loading_widgets.dart`)

**Gunakan sesuai konteks:**

| Widget | Gunakan Untuk |
|--------|---------------|
| `AppSmallLoadingIndicator` | Button loading state |
| `AppLoadingIndicator` | Page/content loading |
| `AppFullScreenLoading` | Full screen overlay |
| `AppDotsLoadingIndicator` | Chat/typing indicator |
| `AppPulseLoadingIndicator` | Payment/transaction |
| `AppRippleLoadingIndicator` | Data sync/refresh |

**Contoh penggunaan di button:**
```dart
ElevatedButton(
  onPressed: state is ProductLoading ? null : _submit,
  child: state is ProductLoading
      ? const AppSmallLoadingIndicator(color: AppColors.white, size: 20.0)
      : const Text("UPLOAD PRODUK"),
)
```

**Loading dialog:**
```dart
showLoadingDialog(context, message: "Memproses pesanan...");
// Don't forget to pop when done:
Navigator.pop(context);
```

---

## Theme & Colors

### AppColors Reference

**SELALU import dan gunakan:**
```dart
import 'package:frontend/core/theme/theme.dart';
```

| Category | Colors |
|----------|--------|
| **Primary** | `AppColors.primary`, `AppColors.primaryDark` |
| **Background** | `AppColors.background`, `AppColors.surface`, `AppColors.surfaceAlt` |
| **Text** | `AppColors.textPrimary`, `AppColors.textSecondary`, `AppColors.textDark`, `AppColors.textMuted` |
| **Semantic** | `AppColors.success`, `AppColors.danger`, `AppColors.warning`, `AppColors.info` |
| **Grey** | `AppColors.grey100` - `AppColors.grey800`, `AppColors.greyLight`, `AppColors.greyMedium` |

### AppBar Pattern

**WAJIB untuk AppBar dengan primary background:**
```dart
// Correct
AppBar(
  title: const Text('Upload Produk'),
  backgroundColor: AppColors.primary,
  foregroundColor: AppColors.white,  // WAJIB!
)

// Wrong - text akan hitam di background coklat
AppBar(
  title: const Text('Upload Produk'),
  backgroundColor: AppColors.primary,
  // Missing foregroundColor
)
```

**Untuk AppBar dengan surface background:**
```dart
AppBar(
  backgroundColor: AppColors.surface,
  elevation: 1,
  centerTitle: true,
  title: const Text(
    'Keranjang',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)
```

### Jangan Hardcode Warna

```dart
// Wrong
Color(0xFF8A6B4F)
Colors.red
Colors.grey[300]

// Correct
AppColors.primary
AppColors.danger
AppColors.greyLight
```

---

## UI Helpers (`core/utils/ui_helpers.dart`)

### SnackBarHelper - Throttled SnackBar

**SELALU gunakan `SnackBarHelper` daripada `ScaffoldMessenger` langsung!**

```dart
// Correct - with throttle protection
SnackBarHelper.showSuccess(context, 'Profil berhasil diperbarui');
SnackBarHelper.showError(context, 'Gagal menyimpan data');
SnackBarHelper.showInfo(context, 'Sedang memproses...');

// Wrong - no throttle, inconsistent
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Message')),
);
```

**Kapan gunakan SnackBarHelper:**
| ✅ Gunakan | ❌ Jangan gunakan |
|-----------|------------------|
| Success/failure setelah action | Form validation errors |
| Network operation results | Inline warnings (stock limit) |
| Post-action confirmation | Load failures (use RetryableContent) |

### RetryableContent - Error State dengan Retry

**Gunakan untuk data loading errors, bukan SnackBar:**

```dart
// 1. Add error state
String? _errorMessage;

// 2. Track error in loadData()
Future<void> loadData() async {
  setState(() {
    isLoading = true;
    _errorMessage = null;
  });

  try {
    final data = await service.fetchData();
    if (!mounted) return;
    setState(() {
      this.data = data;
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      isLoading = false;
    });
  }
}

// 3. Wrap content
body: RetryableContent(
  isLoading: isLoading,
  hasError: _errorMessage != null,
  errorMessage: _errorMessage,
  onRetry: loadData,
  child: _buildContent(),
),
```

### ShakeWidget - Form Validation Animation

**Gunakan untuk inline form validation, bukan SnackBar:**

```dart
// 1. Add shake key and error state
final _nameShakeKey = GlobalKey<ShakeWidgetState>();
String? _nameError;

// 2. Wrap TextField with ShakeWidget
ShakeWidget(
  key: _nameShakeKey,
  child: TextField(
    controller: _nameController,
    decoration: InputDecoration(
      labelText: 'Nama Produk *',
      errorText: _nameError,  // Inline error
    ),
    onChanged: (_) {
      if (_nameError != null) setState(() => _nameError = null);
    },
  ),
),

// 3. On validation failure
void _validate() {
  if (_nameController.text.isEmpty) {
    setState(() => _nameError = 'Nama produk harus diisi');
    _nameShakeKey.currentState?.shake();  // Trigger animation
    return;
  }
  // Continue...
}
```

### EmptyStateWidget - Empty State Display

```dart
EmptyStateWidget(
  message: 'Tidak ada produk',
  subMessage: 'Tambahkan produk pertama Anda',
  icon: Icons.inventory_2_outlined,
  onAction: () => context.push('/upload'),
  actionLabel: 'Tambah Produk',
)
```

### DialogManager - Prevent Duplicate Dialogs

```dart
// Prevents multiple dialogs from stacking
await DialogManager.showAlert(
  context: context,
  title: 'Konfirmasi',
  content: 'Yakin ingin menghapus?',
  confirmText: 'Hapus',
  cancelText: 'Batal',
  onConfirm: () => _deleteItem(),
);
```

### Other Utilities

| Utility | Location | Purpose |
|---------|----------|---------|
| `CurrencyFormatter.rupiah` | `core/utils/currency_formatter.dart` | Format `Rp 25.000` |
| `DateFormatter` | `core/utils/date_formatter.dart` | Format dates consistently |
| `PullToRefresh` | `core/utils/ui_helpers.dart` | Simple pull-to-refresh wrapper |
| `Debouncer` | `core/utils/ui_helpers.dart` | Prevent rapid calls |
| `ButtonDebounceMixin` | `core/utils/ui_helpers.dart` | Mixin for button spam prevention |

---

## Loading Delay Constants (`core/constants/app_constants.dart`)

### Why Loading Delays?

Minimum loading delays prevent "flash of loading state" - when API responses are too fast, users may not register that loading occurred, making the UI feel glitchy.

**Pattern:** Run delay in parallel with API call, not sequentially:

```dart
// ✅ Correct - parallel execution (delay doesn't add to total time)
final dataFuture = repository.fetchData();
final delayFuture = Future.delayed(LoadingDelayConstants.standardList);

final data = await dataFuture;
await delayFuture;

// ❌ Wrong - sequential (adds delay to total time)
final data = await repository.fetchData();
await Future.delayed(Duration(milliseconds: 500));
```

### Available Constants

```dart
import 'package:frontend/core/constants/app_constants.dart';
```

| Constant | Duration | Use For |
|----------|----------|---------|
| `LoadingDelayConstants.standardList` | 500ms | List/grid loading (products, petani, transactions) |
| `LoadingDelayConstants.initialLoad` | 600ms | Initial page load (home categories) |
| `LoadingDelayConstants.fullRefresh` | 1200ms | Pull-to-refresh operations |
| `LoadingDelayConstants.profileUpdate` | 500ms | After profile save (show success message) |

### Example Usage

**In BLoC:**
```dart
Future<void> _onLoadRequested(event, emit) async {
  emit(state.copyWith(status: LoadStatus.loading));

  final dataFuture = _repository.fetchData();
  final delayFuture = Future.delayed(LoadingDelayConstants.standardList);

  final data = await dataFuture;
  await delayFuture;

  emit(state.copyWith(status: LoadStatus.success, data: data));
}
```

**In StatefulWidget:**
```dart
Future<void> _loadData() async {
  setState(() => isLoading = true);

  final dataFuture = service.fetchData();
  final delayFuture = Future.delayed(LoadingDelayConstants.standardList);

  final data = await dataFuture;
  await delayFuture;

  if (!mounted) return;
  setState(() {
    this.data = data;
    isLoading = false;
  });
}
```

### Jangan Hardcode Delay

```dart
// ❌ Wrong - magic number
await Future.delayed(Duration(milliseconds: 500));

// ✅ Correct - centralized constant
await Future.delayed(LoadingDelayConstants.standardList);
```

---

## Navigation (GoRouter)

### Prefer GoRouter Methods

**SELALU gunakan GoRouter context methods daripada Navigator:**

```dart
// ✅ Correct - GoRouter
context.pop();                           // Go back
context.pop(result);                     // Go back with result
context.push('/path');                   // Push route
context.push('/path', extra: data);      // Push with data
context.pushNamed('routeName');          // Push by name
context.go('/path');                     // Replace entire stack

// ❌ Wrong - Navigator (inconsistent with GoRouter)
Navigator.pop(context);
Navigator.push(context, MaterialPageRoute(...));
Navigator.pushNamed(context, '/path');
```

### Async Navigation with Mounted Check

```dart
// ✅ Correct - Check context.mounted
Future<void> _handleAction() async {
  await someAsyncOperation();

  if (!context.mounted) return;  // PENTING!

  context.pop(true);
}

// ❌ Wrong - No mounted check
Future<void> _handleAction() async {
  await someAsyncOperation();
  context.pop(true);  // May crash if widget disposed
}
```

### Passing Data Between Routes

```dart
// Push with extra data
context.push(
  RoutePaths.productDetail,
  extra: {'product': productData, 'isBumdes': true},
);

// Receive in destination screen (via GoRouterState in router config)
// Or via constructor if using extra parameter parsing
```

---

## Common Patterns

### Screen with BLoC

```dart
class FeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FeatureBloc>()..add(FeatureLoadRequested()),
      child: BlocBuilder<FeatureBloc, FeatureState>(
        builder: (context, state) {
          if (state is FeatureLoading) {
            return const AppLoadingIndicator();
          }
          if (state is FeatureFailure) {
            return Center(child: Text('Error: ${state.error}'));
          }
          if (state is FeatureSuccess) {
            return _buildContent(state.data);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

### Screen with Scoped BLoCs (from DI)

```dart
class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access via BlocProvider.value (provided in router/shell)
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Scaffold(...);
      },
    );
  }
}
```

### Form Screen with Multiple BLoCs

```dart
return MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => sl<ProductBloc>()),
    BlocProvider(create: (_) => ProductEditingCubit()),
  ],
  child: BlocListener<ProductBloc, ProductState>(
    listener: (context, state) {
      if (state is ProductSuccess) {
        Navigator.pop(context);
      } else if (state is ProductFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${state.error}')),
        );
      }
    },
    child: BlocBuilder<ProductBloc, ProductState>(
      builder: (ctx, state) => Scaffold(...),
    ),
  ),
);
```

### Mounted Check (Prevent setState after dispose)

**Gunakan `context.mounted` daripada `mounted` untuk async operations:**

```dart
Future<void> loadData() async {
  try {
    final data = await ApiService.fetchData();

    if (!context.mounted) return;  // PENTING! Use context.mounted

    setState(() {
      this.data = data;
      isLoading = false;
    });
  } catch (e) {
    if (!context.mounted) return;

    setState(() => isLoading = false);
    SnackBarHelper.showError(context, 'Gagal memuat data');
  }
}
```

**Note:** `context.mounted` lebih aman daripada `mounted` karena lint `use_build_context_synchronously` akan warn jika tidak di-check.

---

## File Imports

### Common Imports

```dart
// Theme & Colors
import 'package:frontend/core/theme/theme.dart';

// Dependency Injection
import 'package:frontend/core/di/injection.dart';

// UI Helpers (SnackBarHelper, RetryableContent, ShakeWidget, etc.)
import 'package:frontend/core/utils/ui_helpers.dart';

// Currency formatting
import 'package:frontend/core/utils/currency_formatter.dart';

// Loading widgets
import 'package:frontend/core/widgets/loading_widgets.dart';

// BLoC
import 'package:flutter_bloc/flutter_bloc.dart';

// Router
import 'package:go_router/go_router.dart';
import 'package:frontend/core/router/route_constants.dart';
```

### Feature-specific Imports

```dart
// BUMDes widgets
import 'package:frontend/features/bumdes/view/widgets/common_widgets.dart';
import 'package:frontend/features/bumdes/view/widgets/form_field_widgets.dart';

// Product BLoC
import 'package:frontend/features/product/bloc/product_bloc.dart';
import 'package:frontend/features/product/bloc/product_state.dart';
import 'package:frontend/features/product/bloc/product_event.dart';

// Repositories
import 'package:frontend/features/product/repository/product_repository.dart';
```

---

## Quick Reference

### Accessing Dependencies

| Method | When to Use | Example |
|--------|-------------|---------|
| `sl<T>()` | Anywhere, no context | `final repo = sl<ProductRepository>();` |
| `context.read<T>()` | Inside widgets, one-time read | `context.read<CartBloc>().add(CartAdd());` |
| `context.watch<T>()` | Inside widgets, rebuild on change | `final state = context.watch<CartBloc>().state;` |
| `BlocProvider.value()` | Expose existing BLoC to subtree | `BlocProvider.value(value: sl<AuthBloc>())` |

### Folder Import Paths

| From | To | Import Pattern |
|------|-----|----------------|
| Any | Core | `package:frontend/core/...` |
| Any | Feature | `package:frontend/features/feature_name/...` |
| Feature | Core | `package:frontend/core/...` |
| Feature | Another feature | `package:frontend/features/other_feature/...` |
