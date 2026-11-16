import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<String>> getCategories();
  Future<List<ProductModel>> getProductsByCategory(String category);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await apiClient.get(ApiConstants.productsEndpoint);
    if (response is List) {
      return response
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await apiClient.get(ApiConstants.categoriesEndpoint);
    if (response is List) {
      return response.map((item) => item.toString()).toList();
    }
    return [];
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final encoded = Uri.encodeComponent(category);
    final response = await apiClient.get('${ApiConstants.categoryProductsEndpoint}/$encoded');
    if (response is List) {
      return response
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
