import '../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Product>> getProducts() async {
    try {
      final remoteProducts = await remoteDataSource.getProducts();
      // Cache for offline resilience
      await localDataSource.cacheProducts(remoteProducts);
      return remoteProducts;
    } on NetworkException {
      // Fallback to cache
      try {
        final cached = await localDataSource.getLastCachedProducts();
        return cached;
      } catch (cacheError) {
        throw NetworkFailure(
          message: 'Unable to connect to server and no offline cache available.',
        );
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      throw ServerFailure(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await remoteDataSource.getCategories();
    } catch (e) {
      return ['electronics', 'jewelery', "men's clothing", "women's clothing"];
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      return await remoteDataSource.getProductsByCategory(category);
    } catch (e) {
      // Filter from cached products if offline
      try {
        final cached = await localDataSource.getLastCachedProducts();
        return cached.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
      } catch (_) {
        throw ServerFailure(message: 'Failed to fetch category products: $e');
      }
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final all = await getProducts();
      if (query.isEmpty) return all;
      return all.where((p) {
        return p.title.toLowerCase().contains(query.toLowerCase()) ||
            p.category.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw ServerFailure(message: 'Search error: $e');
    }
  }
}
