import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/product/bloc/product_state.dart';

class ProductEditingCubit extends Cubit<ProductEditing> {
  ProductEditingCubit() : super(const ProductEditing());

  void initialize(Map<String, dynamic>? product) {
    if (product == null) {
      emit(const ProductEditing());
      return;
    }

    final contributions = (product['product_contributions'] as List? ?? [])
        .map((contrib) => {
              'petani_id': contrib['petani']['id'],
              'petani_name': contrib['petani']['name'],
              'contributed_kg': double.parse(contrib['contributed_kg'].toString()),
              'harvest_date': contrib['harvest_date'] ??
                  DateTime.now().toIso8601String().split('T')[0],
            })
        .toList()
        .cast<Map<String, dynamic>>();

    final existingImages = (product['product_images'] as List? ?? [])
        .map((img) => {'id': img['id'], 'image_path': img['image_path']})
        .toList()
        .cast<Map<String, dynamic>>();

    emit(ProductEditing(
      petaniContributors: contributions,
      selectedImages: const [],
      existingImages: existingImages,
      imagesToDelete: const [],
    ));
  }

  void addContributor(Map<String, dynamic> contributor) {
    final updated = List<Map<String, dynamic>>.from(state.petaniContributors)
      ..add(contributor);
    emit(state.copyWith(petaniContributors: updated));
  }

  void updateContributor(int index, Map<String, dynamic> contributor) {
    final updated = List<Map<String, dynamic>>.from(state.petaniContributors);
    if (index >= 0 && index < updated.length) {
      updated[index] = contributor;
      emit(state.copyWith(petaniContributors: updated));
    }
  }

  void removeContributor(int index) {
    final updated = List<Map<String, dynamic>>.from(state.petaniContributors);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      emit(state.copyWith(petaniContributors: updated));
    }
  }

  void addImage(File image) {
    final updated = List<File>.from(state.selectedImages)..add(image);
    emit(state.copyWith(selectedImages: updated));
  }

  void removeSelectedImage(int index) {
    final updated = List<File>.from(state.selectedImages);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      emit(state.copyWith(selectedImages: updated));
    }
  }

  void toggleExistingImageDeletion(int imageId) {
    final updated = List<int>.from(state.imagesToDelete);
    if (updated.contains(imageId)) {
      updated.remove(imageId);
    } else {
      updated.add(imageId);
    }
    emit(state.copyWith(imagesToDelete: updated));
  }
}
