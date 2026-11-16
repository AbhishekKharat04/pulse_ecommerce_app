import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInRequestedEvent>(_onSignInRequested);
    on<SignOutRequestedEvent>(_onSignOutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    SignInRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithEmailPassword(
        event.email,
        event.password,
      );
      emit(Authenticated(user));
    } on Failure catch (f) {
      emit(AuthFailure(f.message));
    } catch (e) {
      emit(AuthFailure('Authentication error: $e'));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.signOut();
    emit(Unauthenticated());
  }
}
