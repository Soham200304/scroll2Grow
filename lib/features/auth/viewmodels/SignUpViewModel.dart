import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scrool2grow/features/auth/models/UserModel.dart';
import 'package:scrool2grow/features/auth/services/SignUpService.dart';


final authViewModelProvider =
StateNotifierProvider<AuthViewModel, AuthState>(
      (ref) {
    return AuthViewModel(
      SignUpService(),
    );
  },
);

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = SignUpService();
  return authService.authStateChanges;
});

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final SignUpService _authService;

  AuthViewModel(this._authService) : super(const AuthState());

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      final user = await _authService.signup(
        name: name,
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        user: user,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );

      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      final user = await _authService.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        user: user,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );

      return false;
    }
  }

  String _getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account already exists with this email.';

        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'weak-password':
          return 'Password is too weak.';

        case 'user-not-found':
          return 'No account found with this email.';

        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';

        case 'user-disabled':
          return 'This account has been disabled.';

        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';

        default:
          return error.message ?? 'Something went wrong.';
      }
    }

    return 'Something went wrong. Please try again.';
  }
}