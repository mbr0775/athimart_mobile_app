import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit({
    HomeRepository? repository,
  })  : _repository = repository ?? HomeRepository(),
        super(const HomeState());

  Future<void> loadHomeData() async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final data = await _repository.fetchHomeData();

      emit(HomeState(
        status: HomeStatus.success,
        featuredProducts: data.featuredProducts,
        flashSaleProducts: data.flashSaleProducts,
        newArrivals: data.newArrivals,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }
}