part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();

  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthLoggedIn extends AuthEvent {
  final Map<String, dynamic> user;

  const AuthLoggedIn(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoggedOut extends AuthEvent {}

class AuthStatusChanged extends AuthEvent {
  final bool isAuthenticated;
  final Map<String, dynamic>? user;

  const AuthStatusChanged(this.isAuthenticated, {this.user});

  @override
  List<Object?> get props => [isAuthenticated, user];
}
