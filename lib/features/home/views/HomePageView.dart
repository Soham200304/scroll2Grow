import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrool2grow/app/routes/AppRoutes.dart';
import 'package:scrool2grow/app/themes/app_colors.dart';
import 'package:scrool2grow/features/home/viewmodels/HomeViewModel.dart';
import 'package:scrool2grow/features/notifications/services/NotificationService.dart';


class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();

    // Load Home data when the page is first created.
    Future.microtask(() {
      if (!mounted) return;

      ref.read(homeViewModelProvider.notifier).loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildContent(homeState),
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    if (state.isLoading && state.homeData == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (state.errorMessage != null && state.homeData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 42,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load your Home page.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(homeViewModelProvider.notifier)
                      .loadHomeData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final user = state.homeData;

    if (user == null) {
      return const Center(
        child: Text('No Home data available.'),
      );
    }

    final progress = user.nextLevelXp > 0
        ? (user.currentXp / user.nextLevelXp).clamp(0.0, 1.0)
        : 0.0;

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(homeViewModelProvider.notifier)
            .loadHomeData();
      },
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          // Greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Good ${_getTimeGreeting()}, ${user.name}!!',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
              ),
              InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
              },
                child: Icon(
                  Icons.output,
                  color: AppColors.primary,
                ),
              ),

              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.notificationSettings,
                  );
                },
                child: Icon(
                  Icons.settings,
                  color: AppColors.primary,
                ),
              )
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Ready to grow today?',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Garden summary
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Garden',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Level ${user.gardenLevel}',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${user.currentXp} / ${user.nextLevelXp} XP',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${user.nextLevelXp > user.currentXp ? user.nextLevelXp - user.currentXp : 0} XP until your next growth',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Streak
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.warning,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.streakDays} Day Streak',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Keep your growth going!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Helpful debug/profile information
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // Start Scrolling card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                  AppColors.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.spa_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Ready to grow?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Turn scrolling time into meaningful progress.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.scrollFeed,
                      );

                      if (!mounted) return;

                      await ref
                          .read(homeViewModelProvider.notifier)
                          .refreshHomeData();

                      final granted =
                      await NotificationService.instance.requestPermission();

                      if (granted) {
                        await NotificationService.instance.showTestNotification();
                      }
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Scrolling'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';

    return 'evening';
  }
}