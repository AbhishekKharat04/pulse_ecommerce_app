import '../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase implements UseCase<List<Product>, NoParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<List<Product>> call(NoParams params) async {
    return await repository.getProducts();
  }
}

class GetProductsByCategoryUseCase implements UseCase<List<Product>, String> {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  @override
  Future<List<Product>> call(String category) async {
    return await repository.getProductsByCategory(category);
  }
}

class SearchProductsUseCase implements UseCase<List<Product>, String> {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  @override
  Future<List<Product>> call(String query) async {
    return await repository.searchProducts(query);
  }
}

class GetCategoriesUseCase implements UseCase<List<String>, NoParams> {
  final ProductRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<List<String>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
