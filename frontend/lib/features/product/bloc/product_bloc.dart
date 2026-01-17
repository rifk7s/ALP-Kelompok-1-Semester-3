import 'package:bloc/bloc.dart';
import 'package:frontend/features/product/bloc/product_event.dart';
import 'package:frontend/features/product/bloc/product_state.dart';
import 'package:frontend/features/product/repository/product_repository.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<ProductCreateRequested>(_onCreateRequested);
    on<ProductUpdateRequested>(_onUpdateRequested);
  }

  // Editing responsibilities moved to ProductEditingCubit
  Future<void> _onCreateRequested(
    ProductCreateRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      await repository.createProduct(
        name: event.name,
        categoryId: event.categoryId,
        variety: event.variety,
        storageDays: event.storageDays,
        pricePerKg: event.pricePerKg,
        stockKg: event.stockKg,
        description: event.description,
        petaniContributors: event.petaniContributors,
        images: event.images,
      );
      emit(const ProductSuccess());
    } catch (e) {
      emit(ProductFailure(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    ProductUpdateRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final response = await repository.updateProduct(
        productId: event.productId,
        name: event.name,
        categoryId: event.categoryId,
        variety: event.variety,
        harvestDate: event.harvestDate,
        storageDays: event.storageDays,
        pricePerKg: event.pricePerKg,
        stockKg: event.stockKg,
        description: event.description,
        petaniContributors: event.petaniContributors,
        newImages: event.newImages,
        imageIdsToDelete: event.imageIdsToDelete,
      );

      // If backend returns the updated product object, forward it
      Map<String, dynamic>? product;
      try {
        product = response != null && response['product'] != null
            ? Map<String, dynamic>.from(response['product'])
            : null;
      } catch (_) {
        product = null;
      }

      emit(ProductSuccess(product: product));
    } catch (e) {
      emit(ProductFailure(e.toString()));
    }
  }
}
