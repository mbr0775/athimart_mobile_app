import '../../../core/services/product_service.dart';

class HomeData {
  final List<Map<String, dynamic>> featuredProducts;
  final List<Map<String, dynamic>> flashSaleProducts;
  final List<Map<String, dynamic>> newArrivals;

  const HomeData({
    required this.featuredProducts,
    required this.flashSaleProducts,
    required this.newArrivals,
  });
}

class HomeRepository {
  Future<HomeData> fetchHomeData() async {
    final results = await Future.wait<List<Map<String, dynamic>>>([
      ProductService.getFeaturedProducts(),
      ProductService.getFlashSaleProducts(),
      ProductService.getNewArrivals(),
    ]);

    return HomeData(
      featuredProducts: results[0],
      flashSaleProducts: results[1],
      newArrivals: results[2],
    );
  }
}