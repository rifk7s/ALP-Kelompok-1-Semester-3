import 'package:equatable/equatable.dart';
import 'package:frontend/features/bumdes/service/petani_service.dart';

/// State for PetaniBloc
class PetaniState extends Equatable {
  /// List of all petani
  final List<PetaniData> petaniList;

  /// Whether data is loading
  final bool isLoading;

  /// Whether there's an error
  final bool hasError;

  /// Error message if any
  final String? errorMessage;

  /// Whether a mutation (create/update/delete) is in progress
  final bool isMutating;

  /// Success message for mutations
  final String? successMessage;

  const PetaniState({
    this.petaniList = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.isMutating = false,
    this.successMessage,
  });

  PetaniState copyWith({
    List<PetaniData>? petaniList,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? isMutating,
    String? successMessage,
  }) {
    return PetaniState(
      petaniList: petaniList ?? this.petaniList,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
      isMutating: isMutating ?? this.isMutating,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        petaniList,
        isLoading,
        hasError,
        errorMessage,
        isMutating,
        successMessage,
      ];
}
