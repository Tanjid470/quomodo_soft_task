import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductApiService {
  final ApiClient _apiClient;

  ProductApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all products
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.products,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    if (response.isSuccess && response.data != null) {
      final responseData = response.data as Map<String, dynamic>;

      // Handle paginated response: {"products": {"data": [...]}}
      if (responseData.containsKey('products')) {
        final productsData = responseData['products'];

        // Check if products is a paginated object with 'data' key
        if (productsData is Map<String, dynamic> &&
            productsData.containsKey('data')) {
          final productsList = productsData['data'] as List;
          return productsList
              .map((json) => ProductModel.fromJson(json))
              .toList();
        }
        // Or if products is directly an array
        else if (productsData is List) {
          return productsData
              .map((json) => ProductModel.fromJson(json))
              .toList();
        }
      }

      // Fallback: Check for nested data structure
      if (responseData.containsKey('data')) {
        final data = responseData['data'] as Map<String, dynamic>;

        if (data.containsKey('featured_products')) {
          final productsList = data['featured_products'] as List;
          return productsList
              .map((json) => ProductModel.fromJson(json))
              .toList();
        } else if (data.containsKey('new_arrival_products')) {
          final productsList = data['new_arrival_products'] as List;
          return productsList
              .map((json) => ProductModel.fromJson(json))
              .toList();
        }
      }
    }

    print('⚠️ API Error: ${response.message} (${response.statusCode})');
    return [];
  }

  /// Get product by slug
  Future<ProductModel?> getProductById(String slug) async {
    final response = await _apiClient.get(ApiConstants.getProductById(slug));

    if (response.isSuccess && response.data != null) {
      final responseData = response.data as Map<String, dynamic>;

      // API response structure: {"product": {...}, "gellery": [...], "relatedProducts": [...]}
      if (responseData.containsKey('product')) {
        return ProductModel.fromJson(responseData['product']);
      }
    }

    print('⚠️ API Error: ${response.message} (${response.statusCode})');
    return null;
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final response = await _apiClient.get(
      ApiConstants.getProductsByCategory(categoryId),
    );

    if (response.isSuccess && response.data != null) {
      final responseData = response.data as Map<String, dynamic>;

      // API response structure: {"category": {...}, "products": [...]}
      if (responseData.containsKey('products')) {
        final products = responseData['products'] as List;
        return products.map((json) => ProductModel.fromJson(json)).toList();
      }
    }

    print('⚠️ API Error: ${response.message} (${response.statusCode})');
    return [];
  }

  /// Get all categories from home page data
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiConstants.baseUrl);

    if (response.isSuccess && response.data != null) {
      final responseData = response.data as Map<String, dynamic>;

      // API response structure: {"homepage_categories": [...], "newArrivalProducts": [...]}
      if (responseData.containsKey('homepage_categories')) {
        final categories = responseData['homepage_categories'] as List;
        return categories.map((json) => CategoryModel.fromJson(json)).toList();
      }
    }

    print('⚠️ API Error: ${response.message} (${response.statusCode})');
    return [];
  }

  /// Get home page data (categories and products)
  Future<Map<String, dynamic>?> getHomePageData() async {
    final response = await _apiClient.get(ApiConstants.baseUrl);

    if (response.isSuccess && response.data != null) {
      return response.data as Map<String, dynamic>;
    }

    print('⚠️ API Error: ${response.message} (${response.statusCode})');
    return null;
  }
}
