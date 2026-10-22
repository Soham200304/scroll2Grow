import 'package:scrool2grow/features/scrool_feed/models/ActivityModel.dart';

class RecommendationService {
  static const List<ActivityModel> _activities = [
    ActivityModel(
      id: 'creative_challenge',
      title: 'Try a Creative Challenge',
      description:
      'Draw something around you, write a short story, '
          'or try a small creative task.',
      category: 'Hobby',
      durationMinutes: 5,
    ),
    ActivityModel(
      id: 'breathing_break',
      title: 'Take a Breathing Break',
      description:
      'Sit comfortably and take a few slow, gentle breaths. '
          'Relax your shoulders and give yourself a moment.',
      category: 'Relaxation',
      durationMinutes: 3,
    ),
    ActivityModel(
      id: 'quiet_reading',
      title: 'Enjoy Some Quiet Reading',
      description:
      'Read a few pages of a book or an article you find useful.',
      category: 'Reading',
      durationMinutes: 5,
    ),
    ActivityModel(
      id: 'personal_goal',
      title: 'Make Progress on a Goal',
      description:
      'Spend a few minutes taking one small step toward '
          'a personal goal.',
      category: 'Personal Growth',
      durationMinutes: 10,
    ),
    ActivityModel(
      id: 'short_walk',
      title: 'Take a Short Walk',
      description:
      'Stand up, stretch gently, and take a short walk if possible.',
      category: 'Movement',
      durationMinutes: 5,
    ),
  ];

  ActivityModel recommend({
    required String? mood,
    required int sessionDurationSeconds,
    required DateTime currentTime,
  }) {
    // A long session takes priority over mood-specific rules.
    if (sessionDurationSeconds >= 30 * 60) {
      return _activities.firstWhere(
            (activity) => activity.id == 'short_walk',
      );
    }

    // Tired users late at night get a calming suggestion.
    if (mood == 'Tired' && currentTime.hour >= 21) {
      return _activities.firstWhere(
            (activity) => activity.id == 'quiet_reading',
      );
    }

    switch (mood) {
      case 'Bored':
        return _activities.firstWhere(
              (activity) => activity.id == 'creative_challenge',
        );

      case 'Stressed':
        return _activities.firstWhere(
              (activity) => activity.id == 'breathing_break',
        );

      case 'Tired':
        return _activities.firstWhere(
              (activity) => activity.id == 'quiet_reading',
        );

      case 'Motivated':
        return _activities.firstWhere(
              (activity) => activity.id == 'personal_goal',
        );

      default:
        return _activities.firstWhere(
              (activity) => activity.id == 'personal_goal',
        );
    }
  }
}