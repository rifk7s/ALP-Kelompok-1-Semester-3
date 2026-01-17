import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

/// State used while editing a product (create or update)
class ProductEditing extends ProductState {
  final List<Map<String, dynamic>> petaniContributors;
  final List<File> selectedImages;
  final List<Map<String, dynamic>> existingImages;
  final List<int> imagesToDelete;

  const ProductEditing({
    this.petaniContributors = const [],
    this.selectedImages = const [],
    this.existingImages = const [],
    this.imagesToDelete = const [],
  });

  ProductEditing copyWith({
    List<Map<String, dynamic>>? petaniContributors,
    List<File>? selectedImages,
    List<Map<String, dynamic>>? existingImages,
    List<int>? imagesToDelete,
  }) {
    return ProductEditing(
      petaniContributors: petaniContributors ?? this.petaniContributors,
      selectedImages: selectedImages ?? this.selectedImages,
      existingImages: existingImages ?? this.existingImages,
      imagesToDelete: imagesToDelete ?? this.imagesToDelete,
    );
  }

  @override
  List<Object?> get props => [
    petaniContributors,
    selectedImages,
    existingImages,
    imagesToDelete,
  ];
}

class ProductSuccess extends ProductState {
  final Map<String, dynamic>? product;
  const ProductSuccess({this.product});

  @override
  List<Object?> get props => [product];
}

class ProductFailure extends ProductState {
  final String error;
  const ProductFailure(this.error);

  @override
  List<Object?> get props => [error];
}
