import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scrool2grow/app/routes/AppRoutes.dart';
import 'package:scrool2grow/features/home/views/HomePageView.dart';
import 'package:scrool2grow/features/onboardings/views/OnboardingIntroView.dart';
import 'package:scrool2grow/features/auth/views/LoginView.dart';

class Scrool2GrowApp extends StatelessWidget {
  const Scrool2GrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scroll2Grow',
      home: const StartupGate(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  Future<bool> _hasCompletedIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('introCompleted') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasCompletedIntro(),
      builder: (context, introSnapshot) {
        if (introSnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (introSnapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Unable to initialize the app.'),
            ),
          );
        }

        final introCompleted = introSnapshot.data ?? false;

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final user = authSnapshot.data;

            // Existing authenticated users go directly to Home.
            if (user != null) {
              return const HomePage();
            }

            // First-time users see Intro.
            if (!introCompleted) {
              return const OnboardingIntroView();
            }

            // Returning unauthenticated users go to Login.
            return const LoginView();
          },
        );
      },
    );
  }
}