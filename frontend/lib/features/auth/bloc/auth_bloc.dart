import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/features/auth/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthState()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoggedIn>(_onLoggedIn);
    on<AuthLoggedOut>(_onLoggedOut);
    on<AuthStatusChanged>(_onStatusChanged);
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      final user = await _repository.getStoredUser();
      final role = user?['role'] as String?;

      // Push authenticated scope for returning users
      pushAuthenticatedScope();

      emit(AuthState(status: AuthStatus.authenticated, user: user, role: role));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    // Push authenticated scope for fresh login
    pushAuthenticatedScope();

    final role = event.user['role'] as String?;
    emit(
      AuthState(status: AuthStatus.authenticated, user: event.user, role: role),
    );
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.clearStorage();

    // Pop authenticated scope - cleans up all user-specific instances
    await popAuthenticatedScope();

    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.isAuthenticated) {
      // Push scope if transitioning to authenticated
      pushAuthenticatedScope();

      final role = event.user?['role'] as String?;
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: event.user,
          role: role,
        ),
      );
    } else {
      // Pop scope if transitioning to unauthenticated
      await popAuthenticatedScope();

      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }
}
