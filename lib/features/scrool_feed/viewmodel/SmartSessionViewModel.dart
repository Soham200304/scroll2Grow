import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:scrool2grow/features/scrool_feed/models/ActivityModel.dart';
import 'package:scrool2grow/features/scrool_feed/models/FeedPostModel.dart';
import 'package:scrool2grow/features/scrool_feed/services/FeedService.dart';
import 'package:scrool2grow/features/scrool_feed/services/RecommendationService.dart';
import 'package:scrool2grow/features/scrool_feed/services/SessionService.dart';


class SmartSessionState {
  final List<FeedPost> posts;
  final int total;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int elapsedSeconds;
  final bool isSessionActive;
  final bool isSessionPaused;
  final bool showIntervention;
  final bool thresholdTriggered;
  final String? selectedMood;
  final ActivityModel? recommendedActivity;
  final int earnedXp;
  final Set<String> completedActivityIds;

  const SmartSessionState({
    this.posts = const [],
    this.total = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.elapsedSeconds = 0,
    this.isSessionActive = false,
    this.isSessionPaused = false,
    this.showIntervention = false,
    this.thresholdTriggered = false,
    this.selectedMood,
    this.recommendedActivity,
    this.earnedXp = 0,
    this.completedActivityIds = const {},
  });

  bool get hasMore => posts.length < total;

  SmartSessionState copyWith({
    List<FeedPost>? posts,
    int? total,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    int? elapsedSeconds,
    bool? isSessionActive,
    bool? isSessionPaused,
    bool? showIntervention,
    bool? thresholdTriggered,
    String? selectedMood,
    ActivityModel? recommendedActivity,
    bool clearRecommendation = false,
    int? earnedXp,
    Set<String>? completedActivityIds,
  }) {
    return SmartSessionState(
      posts: posts ?? this.posts,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isSessionPaused: isSessionPaused ?? this.isSessionPaused,
      showIntervention: showIntervention ?? this.showIntervention,
      thresholdTriggered: thresholdTriggered ?? this.thresholdTriggered,
      selectedMood: selectedMood ?? this.selectedMood,
      recommendedActivity: clearRecommendation
          ? null
          : recommendedActivity ?? this.recommendedActivity,
      earnedXp: earnedXp ?? this.earnedXp,
      completedActivityIds:
      completedActivityIds ?? this.completedActivityIds,
    );
  }
}

class SmartSessionViewModel extends StateNotifier<SmartSessionState> {
  final FeedService _feedService;
  static const int interventionThresholdSeconds = 60;
  final RecommendationService _recommendationService =
  RecommendationService();
  final SessionService _sessionService = SessionService();

  final String _sessionId =
  DateTime.now().microsecondsSinceEpoch.toString();

  SmartSessionViewModel(this._feedService)
      : super(const SmartSessionState());

  final Stopwatch _stopwatch = Stopwatch();

  Timer? _ticker;
  bool _initialized = false;
  bool _sessionStarted = false;

  Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;

    await loadInitialPosts();

    if (state.posts.isNotEmpty) {
      _startSession();
    }
  }

  Future<int> completeRecommendedActivity() async {
    final activity = state.recommendedActivity;
    final mood = state.selectedMood;

    if (activity == null ||
        state.completedActivityIds.contains(activity.id)) {
      return 0;
    }

    // Persist the reward before marking it as completed locally.
    final xp = await _sessionService.completeActivity(
      activity: activity,
      mood: mood,
      sessionId: _sessionId,
    );

    if (xp > 0) {
      state = state.copyWith(
        earnedXp: state.earnedXp + xp,
        completedActivityIds: {
          ...state.completedActivityIds,
          activity.id,
        },
      );
    }

    return xp;
  }

  void selectMoodAndRecommend({required String mood}) {
    final activity = _recommendationService.recommend(
      mood: mood,
      sessionDurationSeconds: state.elapsedSeconds,
      currentTime: DateTime.now(),
    );

    state = state.copyWith(
      selectedMood: mood,
      recommendedActivity: activity,
    );
  }

  Future<void> loadInitialPosts() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final page = await _feedService.fetchPosts();

      state = state.copyWith(
        posts: page.posts,
        total: page.total,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );

      if (page.posts.isNotEmpty) {
        _startSession();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load posts. Please try again.',
      );
    }
  }

  Future<void> loadMorePosts() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    state = state.copyWith(
      isLoadingMore: true,
      clearError: true,
    );

    try {
      final page = await _feedService.fetchPosts(
        skip: state.posts.length,
      );

      final existingIds = state.posts.map((post) => post.id).toSet();

      final newPosts = page.posts
          .where((post) => !existingIds.contains(post.id))
          .toList();

      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        total: page.total,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Unable to load more posts.',
      );
    }
  }

  void _startSession() {
    if (_sessionStarted) return;

    _sessionStarted = true;
    _stopwatch.start();

    state = state.copyWith(
      isSessionActive: true,
      isSessionPaused: false,
      clearError: true,
    );

    _ticker = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        final elapsed = _stopwatch.elapsed.inSeconds;

        if (elapsed >= interventionThresholdSeconds &&
            !state.thresholdTriggered) {
          _stopwatch.stop();
          _ticker?.cancel();
          _ticker = null;

          state = state.copyWith(
            elapsedSeconds: elapsed,
            isSessionPaused: true,
            showIntervention: true,
            thresholdTriggered: true,
          );

          return;
        }

        state = state.copyWith(
          elapsedSeconds: elapsed,
        );
      },
    );
  }

  void pauseSession() {
    if (!state.isSessionActive || state.isSessionPaused) return;

    _stopwatch.stop();
    _ticker?.cancel();
    _ticker = null;

    state = state.copyWith(
      elapsedSeconds: _stopwatch.elapsed.inSeconds,
      isSessionPaused: true,
    );
  }

  void resumeSession() {
    if (!state.isSessionActive || !state.isSessionPaused) return;

    _stopwatch.start();

    state = state.copyWith(
      isSessionPaused: false,
    );

    _ticker = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        state = state.copyWith(
          elapsedSeconds: _stopwatch.elapsed.inSeconds,
        );
      },
    );
  }

  void endSession() {
    _stopwatch.stop();
    _ticker?.cancel();
    _ticker = null;

    state = state.copyWith(
      elapsedSeconds: _stopwatch.elapsed.inSeconds,
      isSessionActive: false,
      isSessionPaused: false,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _feedService.dispose();
    super.dispose();
  }
}

final smartSessionViewModelProvider = StateNotifierProvider.autoDispose<
    SmartSessionViewModel, SmartSessionState>((ref) {
  return SmartSessionViewModel(FeedService());
});