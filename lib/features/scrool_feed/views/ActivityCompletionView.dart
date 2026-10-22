import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrool2grow/app/themes/app_colors.dart';
import 'package:scrool2grow/features/scrool_feed/viewmodel/SmartSessionViewModel.dart';


class ActivityCompletionView extends ConsumerStatefulWidget {
  const ActivityCompletionView({super.key});

  @override
  ConsumerState<ActivityCompletionView> createState() =>
      _ActivityCompletionViewState();
}

class _ActivityCompletionViewState
    extends ConsumerState<ActivityCompletionView> {
  bool _completed = false;
  int _earnedXp = 0;
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _completeActivity() async {
    if (_completed || _isSaving) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final xp = await ref
          .read(smartSessionViewModelProvider.notifier)
          .completeRecommendedActivity();

      if (!mounted) return;

      setState(() {
        _completed = xp > 0;
        _earnedXp = xp;
        _isSaving = false;

        if (xp == 0) {
          _errorMessage =
          'This activity reward has already been claimed.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _errorMessage =
        'Could not save your reward. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartSessionViewModelProvider);
    final activity = state.recommendedActivity;

    if (activity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Activity')),
        body: const Center(
          child: Text('No activity selected.'),
        ),
      );
    }

    final alreadyCompleted =
    state.completedActivityIds.contains(activity.id);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: const Text('Your Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(
              _completed
                  ? Icons.emoji_events_rounded
                  : Icons.spa_rounded,
              size: 88,
              color: const Color(0xFF238653),
            ),
            const SizedBox(height: 24),
            Text(
              _completed
                  ? 'Well done!'
                  : activity.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _completed
                  ? 'You completed your activity and earned '
                  '$_earnedXp XP!'
                  : activity.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (!_completed)
              Card(
                elevation: 0,
                color: const Color(0xFFDDF7E8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Your goal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Spend ${activity.durationMinutes} minutes '
                            'on this activity, then mark it complete.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            if (_completed)
              const Chip(
                avatar: Icon(Icons.stars_rounded),
                label: Text('XP reward claimed'),
              ),
            const Spacer(),
            if (!_completed && !alreadyCompleted)
              InkWell(
                borderRadius: BorderRadius.circular(20.0),
                onTap: _isSaving || _completed
                    ? null
                    : _completeActivity,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: AppColors.primaryDark
                  ),
                  child: _isSaving
                      ? Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                      : Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: const Text('Complete Activity', style: TextStyle(fontSize: 15, color: Colors.white),),
                        ),
                      ),
                ),
              ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (alreadyCompleted && !_completed)
              const Text(
                'You have already claimed the reward for this '
                    'activity in this session.',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Recommendation', style: TextStyle(color: AppColors.textPrimary),),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}