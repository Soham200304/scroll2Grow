import 'package:flutter/material.dart';
import 'package:scrool2grow/app/themes/app_colors.dart';

class MoodSelectionView extends StatelessWidget {
  const MoodSelectionView({super.key});

  static const List<Map<String, dynamic>> moods = [
    {
      'name': 'Bored',
      'emoji': '😐',
      'description': 'I need something interesting',
      'color': Color(0xFFFFF0D9),
    },
    {
      'name': 'Stressed',
      'emoji': '😣',
      'description': 'I need to relax',
      'color': Color(0xFFFFE4E6),
    },
    {
      'name': 'Tired',
      'emoji': '😴',
      'description': 'I need something gentle',
      'color': Color(0xFFE5E7FF),
    },
    {
      'name': 'Motivated',
      'emoji': '💪',
      'description': 'I want to make progress',
      'color': Color(0xFFDDF7E8),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Take a Break'),
        backgroundColor: AppColors.backgroundLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your current mood. We’ll suggest a small '
                  'activity that fits how you feel.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: moods.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final mood = moods[index];

                  return Card(
                    elevation: 0,
                    color: mood['color'] as Color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: Text(
                        mood['emoji'] as String,
                        style: const TextStyle(fontSize: 30),
                      ),
                      title: Text(
                        mood['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      subtitle: Text(
                        mood['description'] as String,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                      ),
                      onTap: () {
                        Navigator.pop(
                          context,
                          mood['name'] as String,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}