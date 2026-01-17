import 'package:equatable/equatable.dart';

/// Events for PetaniBloc
abstract class PetaniEvent extends Equatable {
  const PetaniEvent();
  @override
  List<Object?> get props => [];
}

/// Request to load all petani
class PetaniLoadRequested extends PetaniEvent {
  /// If true, shows loading spinner; false for silent refresh
  final bool showSpinner;

  const PetaniLoadRequested({this.showSpinner = true});

  @override
  List<Object?> get props => [showSpinner];
}

/// Request to create new petani
class PetaniCreateRequested extends PetaniEvent {
  final String name;
  final String? phone;
  final String? address;

  const PetaniCreateRequested({
    required this.name,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [name, phone, address];
}

/// Request to update petani
class PetaniUpdateRequested extends PetaniEvent {
  final int id;
  final String name;
  final String? phone;
  final String? address;

  const PetaniUpdateRequested({
    required this.id,
    required this.name,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [id, name, phone, address];
}

/// Request to delete petani
class PetaniDeleteRequested extends PetaniEvent {
  final int id;

  const PetaniDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Reset bloc state
class PetaniReset extends PetaniEvent {
  const PetaniReset();
}
