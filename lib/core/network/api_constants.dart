/// API Constants for all endpoints and base URL
class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://mamunuiux.com/flutter_task/api';

  // Image Base URL
  static const String imageBaseUrl = 'https://mamunuiux.com/flutter_task/';

  // Products Endpoints
  static const String products = '/product';
  static const String productBySlug = '/product/'; // append slug
  static const String productsByCategory =
      '/product-by-category/'; // append categoryId

  // Helper methods
  static String getProductById(String slug) => '$productBySlug$slug';
  static String getProductsByCategory(String categoryId) =>
      '$productsByCategory$categoryId';

  // Helper to get full image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return '$imageBaseUrl$imagePath';
  }
}
