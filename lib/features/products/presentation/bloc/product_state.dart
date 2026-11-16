import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {
  final bool isRefreshing;
  const ProductLoading({this.isRefreshing = false});

  @override
  List<Object?> get props => [isRefreshing];
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;

  const ProductLoaded({
    required this.products,
    required this.filteredProducts,
    required this.categories,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  ProductLoaded copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        products,
        filteredProducts,
        categories,
        selectedCategory,
        searchQuery,
      ];
}

class ProductError extends ProductState {
  final String message;
  final bool isOffline;

  const ProductError({required this.message, this.isOffline = false});

  @override
  List<Object?> get props => [message, isOffline];
}
