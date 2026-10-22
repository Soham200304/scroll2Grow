import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrool2grow/app/themes/app_colors.dart';
import 'package:scrool2grow/features/scrool_feed/viewmodel/SmartSessionViewModel.dart';
import 'package:scrool2grow/features/scrool_feed/views/ActivityCompletionView.dart';

class RecommendationView extends ConsumerWidget {
  const RecommendationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(smartSessionViewModelProvider);
    final activity = sessionState.recommendedActivity;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: const Text('Your Next Step'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: activity == null
            ? const Center(
          child: Text(
            'No activity recommendation is available yet.',
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Center(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: const BoxDecoration(
                  color: Color(0xFFDDF7E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_outlined,
                  size: 64,
                  color: Color(0xFF238653),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'You’re feeling ${sessionState.selectedMood?.toLowerCase() ?? 'ready for a change'}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                activity.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              activity.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Center(
              child: Chip(
                avatar: const Icon(Icons.schedule, size: 18),
                label: Text(
                  '${activity.durationMinutes} minutes · '
                      '${activity.category}',
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActivityCompletionView(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  child: Center(child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text('Let\'s do it', style: TextStyle(fontSize: 15, color: Colors.white),),
                  )),
                ),
              )
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Feed', style: TextStyle(color: AppColors.textPrimary),),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}