enum HomeStatus {
  initial,
  loading,
  success,
  failure,
}

class HomeState {
  final HomeStatus status;
  final List<Map<String, dynamic>> featuredProducts;
  final List<Map<String, dynamic>> flashSaleProducts;
  final List<Map<String, dynamic>> newArrivals;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.featuredProducts = const [],
    this.flashSaleProducts = const [],
    this.newArrivals = const [],
    this.errorMessage,
  });

  bool get isLoading => status == HomeStatus.loading;
  bool get hasError => status == HomeStatus.failure;

  HomeState copyWith({
    HomeStatus? status,
    List<Map<String, dynamic>>? featuredProducts,
    List<Map<String, dynamic>>? flashSaleProducts,
    List<Map<String, dynamic>>? newArrivals,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      flashSaleProducts: flashSaleProducts ?? this.flashSaleProducts,
      newArrivals: newArrivals ?? this.newArrivals,
      errorMessage: errorMessage,
    );
  }
}