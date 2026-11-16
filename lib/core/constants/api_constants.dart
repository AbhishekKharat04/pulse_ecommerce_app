class ApiConstants {
  static const String baseUrl = 'https://fakestoreapi.com';
  static const String productsEndpoint = '$baseUrl/products';
  static const String categoriesEndpoint = '$baseUrl/products/categories';
  static const String categoryProductsEndpoint = '$baseUrl/products/category';

  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Cache keys
  static const String cachedProductsKey = 'CACHED_PRODUCTS_KEY';
  static const String cachedCartKey = 'CACHED_CART_KEY';
  static const String cachedThemeKey = 'CACHED_THEME_KEY';
  static const String cachedUserKey = 'CACHED_USER_KEY';
}
