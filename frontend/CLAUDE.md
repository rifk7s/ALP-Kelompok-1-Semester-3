# CLAUDE.md - Frontend (Flutter)

> Lihat juga: [Root CLAUDE.md](../CLAUDE.md) untuk project-wide guidelines.

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
| **Global** | `core/auth/bloc/` | AuthBloc (dipakai seluruh app) |
| **Feature** | `features/feature/bloc/` | CartBloc, HomeBloc, ProductBloc |

---

## Widget Patterns

### Widget Organization

```
features/feature_name/
├── screens/           # Full page widgets
│   └── feature_screen.dart
└── widgets/           # Reusable components
    ├── feature_card.dart
    └── feature_list.dart

core/widgets/          # Shared across ALL features
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

**Form Widgets** (`features/bumdes/widgets/`):
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

## Common Patterns

### Screen with BLoC

```dart
class FeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeatureBloc()..add(FeatureLoadRequested()),
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

### Form Screen with Multiple BLoCs

```dart
return MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => ProductBloc(repository: ProductRepository())),
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

```dart
Future<void> loadData() async {
  try {
    final data = await ApiService.fetchData();

    if (!mounted) return;  // PENTING!

    setState(() {
      this.data = data;
      isLoading = false;
    });
  } catch (e) {
    if (mounted) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  }
}
```

---

## File Imports

### Common Imports

```dart
// Theme & Colors
import 'package:frontend/core/theme/theme.dart';

// Loading widgets
import 'package:frontend/core/widgets/loading_widgets.dart';

// BLoC
import 'package:flutter_bloc/flutter_bloc.dart';

// Router
import 'package:go_router/go_router.dart';
```

### Feature-specific Imports

```dart
// BUMDes widgets
import 'package:frontend/features/bumdes/widgets/common_widgets.dart';
import 'package:frontend/features/bumdes/widgets/form_field_widgets.dart';

// Product BLoC
import 'package:frontend/features/product/bloc/product_bloc.dart';
import 'package:frontend/features/product/bloc/product_state.dart';
import 'package:frontend/features/product/bloc/product_event.dart';
```
