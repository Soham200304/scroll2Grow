import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scrool2grow/features/scrool_feed/models/ActivityModel.dart';

class SessionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> completeActivity({
    required ActivityModel activity,
    required String? mood,
    required String sessionId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    final userRef = _firestore
        .collection('users')
        .doc(user.uid);

    final completionRef = userRef
        .collection('activity_completions')
        .doc('${sessionId}_${activity.id}');

    final xp = activity.durationMinutes * 2;

    // Use local calendar dates for daily streak tracking.
    final now = DateTime.now();
    final today = _dateKey(now);
    final yesterday = _dateKey(
      now.subtract(const Duration(days: 1)),
    );

    return _firestore.runTransaction<int>((transaction) async {
      // Read all documents before writing.
      final completionSnapshot =
      await transaction.get(completionRef);

      if (completionSnapshot.exists) {
        return 0;
      }

      final userSnapshot = await transaction.get(userRef);

      if (!userSnapshot.exists) {
        throw Exception('User profile not found in Firestore.');
      }

      final userData = userSnapshot.data();

      if (userData == null) {
        throw Exception('Unable to retrieve user profile.');
      }

      final currentXp =
          (userData['currentXp'] as num?)?.toInt() ?? 0;

      final currentStreak =
          (userData['streakDays'] as num?)?.toInt() ?? 0;

      final longestStreak =
          (userData['longestStreak'] as num?)?.toInt() ?? 0;

      final lastActivityDate =
      userData['lastActivityDate'] as String?;

      int newStreak;

      if (lastActivityDate == today) {
        // Another activity today: keep the same streak.
        newStreak = currentStreak;
      } else if (lastActivityDate == yesterday) {
        // Activity completed on consecutive calendar days.
        newStreak = currentStreak + 1;
      } else {
        // First activity or a missed day.
        newStreak = 1;
      }

      final newLongestStreak =
      newStreak > longestStreak ? newStreak : longestStreak;

      transaction.update(userRef, {
        'currentXp': currentXp + xp,
        'streakDays': newStreak,
        'longestStreak': newLongestStreak,
        'lastActivityDate': today,
      });

      transaction.set(completionRef, {
        'activityId': activity.id,
        'activityTitle': activity.title,
        'category': activity.category,
        'durationMinutes': activity.durationMinutes,
        'mood': mood,
        'xpEarned': xp,
        'completedAt': FieldValue.serverTimestamp(),
        'sessionId': sessionId,
        'activityDate': today,
      });

      return xp;
    });
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}