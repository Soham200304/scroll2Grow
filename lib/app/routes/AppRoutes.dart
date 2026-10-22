import 'package:flutter/material.dart';
import 'package:scrool2grow/app/core/utils/page_transitions.dart';
import 'package:scrool2grow/features/auth/views/AuthGate.dart';
import 'package:scrool2grow/features/auth/views/LoginView.dart';
import 'package:scrool2grow/features/auth/views/SignUpView.dart';
import 'package:scrool2grow/features/home/views/HomePageView.dart';
import 'package:scrool2grow/features/notifications/views/NotificationSettingsView.dart';
import 'package:scrool2grow/features/onboardings/views/OnboardingIntroView.dart';
import 'package:scrool2grow/features/scrool_feed/views/ActivityCompletionView.dart';
import 'package:scrool2grow/features/scrool_feed/views/MoodSelectionView.dart';
import 'package:scrool2grow/features/scrool_feed/views/RecommendationView.dart';
import 'package:scrool2grow/features/scrool_feed/views/ScrollFeedView.dart';



class AppRoutes {
  static const String authGate = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String intro = '/intro';

  // Scroll2Grow routes
  static const String scrollFeed = '/scroll-feed';
  static const String moodSelection = '/mood-selection';
  static const String recommendation = '/recommendation';
  static const String activityCompletion = '/activity-completion';
  static const String notificationSettings = '/notification-settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authGate:
        return PageTransitions.slideFromRight(
          const AuthGate(),
        );

      case login:
        return PageTransitions.slideFromRight(
          const LoginView(),
        );

      case signup:
        return PageTransitions.slideFromRight(
          const SignUpView(),
        );

      case home:
        return PageTransitions.slideFromRight(
          const HomePage(),
        );

      case intro:
        return PageTransitions.slideFromRight(
          const OnboardingIntroView(),
        );

    // Scroll2Grow screens
      case scrollFeed:
        return PageTransitions.slideFromRight(
          const ScrollFeedView(),
        );

      case moodSelection:
        return PageTransitions.slideFromRight(
          const MoodSelectionView(),
        );

      case recommendation:
        return PageTransitions.slideFromRight(
          const RecommendationView(),
        );

      case activityCompletion:
        return PageTransitions.slideFromRight(
          const ActivityCompletionView(),
        );

      case notificationSettings:
        return PageTransitions.slideFromRight(
          const NotificationSettingsView(),
        );

      default:
        return PageTransitions.slideFromRight(
          const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}