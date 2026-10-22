import 'package:flutter_riverpod/legacy.dart';
import 'package:scrool2grow/features/home/model/HomeModel.dart';
import 'package:scrool2grow/features/home/services/HomeServices.dart';

class HomeState {
  final bool isLoading;
  final HomeModel? homeData;
  final String? errorMessage;

  const HomeState({
    this.isLoading = false,
    this.homeData,
    this.errorMessage,
  });
}

class HomeViewModel extends StateNotifier<HomeState> {
  final HomeService _homeService;

  HomeViewModel(this._homeService) : super(const HomeState());

  Future<void> loadHomeData() async {
    state = HomeState(
      isLoading: true,
      homeData: state.homeData,
    );

    try {
      final data = await _homeService.getHomeData();

      state = HomeState(
        isLoading: false,
        homeData: data,
      );
    } catch (e) {
      state = HomeState(
        isLoading: false,
        homeData: state.homeData,
        errorMessage: e.toString(),
      );
    }
  }

  // Refresh Home data after returning from another screen.
  Future<void> refreshHomeData() async {
    await loadHomeData();
  }
}

final homeViewModelProvider =
StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(HomeService());
});