# Flutter Patterns & Examples

> Detailed code examples and patterns for the BUMDes Flutter app.
> For quick reference, see [CLAUDE.md](../CLAUDE.md).

---

## Table of Contents

1. [Dependency Injection](#dependency-injection)
2. [State Management (BLoC)](#state-management-bloc)
3. [Repository Pattern](#repository-pattern)
4. [Caching](#caching)
5. [UI Helpers](#ui-helpers)
6. [Loading Delays](#loading-delays)
7. [Common Screen Patterns](#common-screen-patterns)

---

## Dependency Injection

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

### Scope-based Lifecycle

**Base Scope** (persists across login/logout):
- AuthBloc, AuthRepository
- ProductRepository, CategoryRepository
- BumdesRepository, PetaniRepository

**Authenticated Scope** (fresh per session, popped on logout):
- CartBloc, HomeBloc, ProductDetailBloc
- CartRepository, OrderRepository, NotificationRepository

---

## State Management (BLoC)

### BLoC File Structure

```
features/feature_name/bloc/
├── feature_bloc.dart      # BLoC class
├── feature_event.dart     # Events
└── feature_state.dart     # States
```

### Event Naming Convention

```dart
// Correct - use FeatureActionRequested pattern
class ProductCreateRequested extends ProductEvent {}
class CartItemAdded extends CartEvent {}
class AuthLoginRequested extends AuthEvent {}

// Wrong
class CreateProduct extends ProductEvent {}  // No "Requested"
class AddCartItem extends CartEvent {}       // Verb at front
```

### State Classes

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

### State with Data (for editing)

```dart
class ProductEditing extends ProductState {
  final List<Map<String, dynamic>> petaniContributors;
  final List<File> selectedImages;

  // ALWAYS implement copyWith for immutability
  ProductEditing copyWith({...}) {
    return ProductEditing(
      petaniContributors: petaniContributors ?? this.petaniContributors,
      ...
    );
  }
}
```

### Cubit Pattern (Simple State)

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

### BLoC with Repository

```dart
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

---

## Repository Pattern

### Example Repository

```dart
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

### Register and Use

```dart
// Register in DI
sl.registerLazySingleton<ProductRepository>(() => ProductRepository());
sl.registerFactory<ProductBloc>(
  () => ProductBloc(repository: sl<ProductRepository>()),
);

// Use in screen
BlocProvider(
  create: (_) => sl<ProductBloc>()..add(ProductLoadRequested()),
  child: ...,
)
```

---

## Caching

### CacheHelper Usage

```dart
import 'package:frontend/core/cache/cache_helper.dart';

// Get cached data (returns null if expired or not found)
final cached = CacheHelper.get<List<dynamic>>('products');

// Set data with TTL
CacheHelper.set('products', data, CacheDurations.productList);

// Invalidate specific key
CacheHelper.invalidate('products');

// Invalidate all keys starting with pattern
CacheHelper.invalidatePattern('product');  // Clears 'products', 'product:123', etc.
```

### CacheDurations

| Constant | Duration | Use For |
|----------|----------|---------|
| `CacheDurations.categories` | 10 min | Category list |
| `CacheDurations.productList` | 3 min | Product lists |
| `CacheDurations.productDetail` | 2 min | Single product |
| `CacheDurations.petaniList` | 5 min | Petani lists |
| `CacheDurations.bumdesData` | 2 min | Dashboard data |
| `CacheDurations.shortLived` | 1 min | Frequently changing |

### Repository with Caching

```dart
class CategoryRepository {
  static const _cacheKey = 'categories';

  Future<List<dynamic>> getCategories({bool forceRefresh = false}) async {
    // Check cache first (unless force refresh)
    if (!forceRefresh) {
      final cached = CacheHelper.get<List<dynamic>>(_cacheKey);
      if (cached != null) return cached;
    }

    // Fetch from service
    final data = await CategoryService.getCategories();

    // Store in cache
    CacheHelper.set(_cacheKey, data, CacheDurations.categories);

    return data;
  }
}
```

### Cache Invalidation on Mutations

```dart
Future<void> createProduct(...) async {
  await ProductService.createProduct(...);

  // Invalidate all product-related caches
  CacheHelper.invalidatePattern('product');
}
```

---

## UI Helpers

### RetryableContent - Error State with Retry

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
      errorText: _nameError,
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
    _nameShakeKey.currentState?.shake();
    return;
  }
}
```

### EmptyStateWidget

```dart
EmptyStateWidget(
  message: 'Tidak ada produk',
  subMessage: 'Tambahkan produk pertama Anda',
  icon: Icons.inventory_2_outlined,
  onAction: () => context.push('/upload'),
  actionLabel: 'Tambah Produk',
)
```

### DialogManager

```dart
await DialogManager.showAlert(
  context: context,
  title: 'Konfirmasi',
  content: 'Yakin ingin menghapus?',
  confirmText: 'Hapus',
  cancelText: 'Batal',
  onConfirm: () => _deleteItem(),
);
```

---

## Loading Delays

### Why Loading Delays?

Minimum loading delays prevent "flash of loading state" when API is too fast.

### Pattern - Parallel Execution

```dart
// Correct - parallel execution (delay doesn't add to total time)
final dataFuture = repository.fetchData();
final delayFuture = Future.delayed(LoadingDelayConstants.standardList);

final data = await dataFuture;
await delayFuture;

// Wrong - sequential (adds delay to total time)
final data = await repository.fetchData();
await Future.delayed(Duration(milliseconds: 500));
```

### Available Constants

| Constant | Duration | Use For |
|----------|----------|---------|
| `LoadingDelayConstants.standardList` | 500ms | List/grid loading |
| `LoadingDelayConstants.initialLoad` | 600ms | Initial page load |
| `LoadingDelayConstants.fullRefresh` | 1200ms | Pull-to-refresh |
| `LoadingDelayConstants.profileUpdate` | 500ms | Profile save feedback |

### Example in BLoC

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

---

## Common Screen Patterns

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
        context.pop();
      } else if (state is ProductFailure) {
        SnackBarHelper.showError(context, state.error);
      }
    },
    child: BlocBuilder<ProductBloc, ProductState>(
      builder: (ctx, state) => Scaffold(...),
    ),
  ),
);
```

### Mounted Check Pattern

```dart
Future<void> loadData() async {
  try {
    final data = await ApiService.fetchData();

    if (!context.mounted) return;  // IMPORTANT!

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

---

## BUMDes Form Widgets

```dart
// Section card with title
BumdesSectionCard(
  title: "Informasi Utama",
  child: Column(...),
)

// Input label with required indicator
BumdesInputLabel("Nama Produk", required: true)  // Renders: "Nama Produk *"

// Price field with auto-formatting
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

---

## Loading Widgets

| Widget | Use For |
|--------|---------|
| `AppSmallLoadingIndicator` | Button loading state |
| `AppLoadingIndicator` | Page/content loading |
| `AppFullScreenLoading` | Full screen overlay |
| `AppDotsLoadingIndicator` | Chat/typing indicator |
| `AppPulseLoadingIndicator` | Payment/transaction |
| `AppRippleLoadingIndicator` | Data sync/refresh |

**Button loading example:**
```dart
ElevatedButton(
  onPressed: state is ProductLoading ? null : _submit,
  child: state is ProductLoading
      ? const AppSmallLoadingIndicator(color: AppColors.white, size: 20.0)
      : const Text("UPLOAD PRODUK"),
)
```

---

*For quick reference rules, see [CLAUDE.md](../CLAUDE.md)*
