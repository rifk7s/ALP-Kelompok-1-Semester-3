import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}
class ProductCreateRequested extends ProductEvent {
  final String name;
  final int categoryId;
  final String variety;
  final int storageDays;
  final double pricePerKg;
  final double stockKg;
  final String? description;
  final List<Map<String, dynamic>> petaniContributors;
  final List<File>? images;

  const ProductCreateRequested({
    required this.name,
    required this.categoryId,
    required this.variety,
    required this.storageDays,
    required this.pricePerKg,
    required this.stockKg,
    this.description,
    required this.petaniContributors,
    this.images,
  });

  @override
  List<Object?> get props => [name, categoryId, variety, storageDays, pricePerKg, stockKg];
}

class ProductUpdateRequested extends ProductEvent {
  final int productId;
  final String name;
  final int categoryId;
  final String variety;
  final String harvestDate;
  final int storageDays;
  final double pricePerKg;
  final double stockKg;
  final String? description;
  final List<Map<String, dynamic>> petaniContributors;
  final List<File>? newImages;
  final List<int>? imageIdsToDelete;

  const ProductUpdateRequested({
    required this.productId,
    required this.name,
    required this.categoryId,
    required this.variety,
    required this.harvestDate,
    required this.storageDays,
    required this.pricePerKg,
    required this.stockKg,
    this.description,
    required this.petaniContributors,
    this.newImages,
    this.imageIdsToDelete,
  });

  @override
  List<Object?> get props => [productId, name, categoryId, variety, harvestDate, storageDays, pricePerKg, stockKg];
}

