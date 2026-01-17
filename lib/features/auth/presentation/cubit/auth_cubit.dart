import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sca_members_clubs/features/auth/domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  /// Check if user has existing session on app startup
  Future<void> checkExistingSession() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthSessionRestored(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  /// Login with username and password
  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(username, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError("خطأ في بيانات تسجيل الدخول"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError("خطأ في تسجيل الخروج: ${e.toString()}"));
    }
  }
}
