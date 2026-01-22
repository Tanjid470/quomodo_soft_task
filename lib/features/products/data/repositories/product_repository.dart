import '../datasources/product_api_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ProductApiService _apiService;

  ProductRepository({ProductApiService? apiService})
      : _apiService = apiService ?? ProductApiService();

  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _apiService.getProducts(page: page, limit: limit);
    } catch (e) {
      print('Error in ProductRepository.getProducts: $e');
      rethrow;
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      return await _apiService.getProductById(id);
    } catch (e) {
      print('Error in ProductRepository.getProductById: $e');
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      return await _apiService.getProductsByCategory(categoryId);
    } catch (e) {
      print('Error in ProductRepository.getProductsByCategory: $e');
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      return await _apiService.getCategories();
    } catch (e) {
      print('Error in ProductRepository.getCategories: $e');
      rethrow;
    }
  }
}
