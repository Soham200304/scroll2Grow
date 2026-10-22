import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scrool2grow/app/themes/app_colors.dart';
import 'package:scrool2grow/features/scrool_feed/models/FeedPostModel.dart';
import 'package:scrool2grow/features/scrool_feed/viewmodel/SmartSessionViewModel.dart';
import 'package:scrool2grow/features/scrool_feed/views/MoodSelectionView.dart';
import 'package:scrool2grow/features/scrool_feed/views/RecommendationView.dart';


class ScrollFeedView extends ConsumerStatefulWidget {
  const ScrollFeedView({super.key});

  @override
  ConsumerState<ScrollFeedView> createState() => _ScrollFeedViewState();
}

class _ScrollFeedViewState extends ConsumerState<ScrollFeedView>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_handleScroll);

    Future.microtask(() {
      if (!mounted) return;

      ref.read(smartSessionViewModelProvider.notifier).initialize();
    });
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 400) {
      ref.read(smartSessionViewModelProvider.notifier).loadMorePosts();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final viewModel = ref.read(smartSessionViewModelProvider.notifier);

    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.hidden) {
      viewModel.pauseSession();
    } else if (lifecycleState == AppLifecycleState.resumed) {
      viewModel.resumeSession();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();

    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showInterventionDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Time for a mindful break?'),
          content: const Text(
            "You've been scrolling for a while. "
                'Would you like to take a break or continue?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ref
                    .read(smartSessionViewModelProvider.notifier)
                    .resumeSession();
              },
              child: const Text('Continue scrolling', style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _openMoodSelection();
              },
              child: const Text('Take a break', style: TextStyle(color: AppColors.textPrimary),),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openMoodSelection() async {
    final mood = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const MoodSelectionView(),
      ),
    );

    if (!mounted || mood == null) return;

    ref
        .read(smartSessionViewModelProvider.notifier)
        .selectMoodAndRecommend(mood: mood);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RecommendationView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SmartSessionState>(
      smartSessionViewModelProvider,
          (previous, next) {
        if (previous?.showIntervention != true &&
            next.showIntervention) {
          _showInterventionDialog();
        }
      },
    );
    final state = ref.watch(smartSessionViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Smart Scroll',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  state.isSessionPaused
                      ? Icons.pause_circle_outline
                      : Icons.timer_outlined,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDuration(state.elapsedSeconds),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildFeed(state),
    );
  }

  Widget _buildFeed(SmartSessionState state) {
    if (state.isLoading && state.posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (state.errorMessage != null && state.posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Could not load your feed',
                style: TextStyle(
                  fontSize: 18,
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
                      .read(smartSessionViewModelProvider.notifier)
                      .loadInitialPosts();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.posts.isEmpty) {
      return const Center(
        child: Text('No posts available.'),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        return ref
            .read(smartSessionViewModelProvider.notifier)
            .loadInitialPosts();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: state.posts.length + 1,
        itemBuilder: (context, index) {
          if (index == state.posts.length) {
            return _buildFeedFooter(state);
          }

          return _buildPostCard(state.posts[index]);
        },
      ),
    );
  }

  Widget _buildPostCard(FeedPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.surfaceMint,
                child: Text(
                  'U${post.userId}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Community post #${post.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.more_horiz,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            post.title,
            style: const TextStyle(
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            post.body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),

          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(
                Icons.favorite_border_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${post.likes}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.visibility_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${post.views} views',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedFooter(SmartSessionState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (state.errorMessage != null && state.posts.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextButton(
            onPressed: () {
              ref
                  .read(smartSessionViewModelProvider.notifier)
                  .loadMorePosts();
            },
            child: const Text('Failed to load more posts. Retry'),
          ),
        ),
      );
    }

    if (!state.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            "You've reached the end of the feed.",
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: 20);
  }
}