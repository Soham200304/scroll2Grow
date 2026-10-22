import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrool2grow/features/auth/viewmodels/SignUpViewModel.dart';
import 'package:scrool2grow/features/auth/views/LoginView.dart';
import 'package:scrool2grow/features/home/views/HomePageView.dart';


class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('AUTH GATE BUILD');

    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomePage();
        }

        return const LoginView();
      },

      loading: () {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },

      error: (error, stackTrace) {
        return const LoginView();
      },
    );
  }
}