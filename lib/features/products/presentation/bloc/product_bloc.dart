import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
  }) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
  }

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const ProductLoading());
    }

    try {
      final productsFuture = getProductsUseCase(NoParams());
      final categoriesFuture = getCategoriesUseCase(NoParams());

      final results = await Future.wait([productsFuture, categoriesFuture]);
      final products = results[0] as List;
      final categoriesRaw = results[1] as List<String>;
      final categories = ['All', ...categoriesRaw];

      emit(ProductLoaded(
        products: products.cast(),
        filteredProducts: products.cast(),
        categories: categories,
        selectedCategory: 'All',
      ));
    } on NetworkFailure catch (e) {
      emit(ProductError(message: e.message, isOffline: true));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  void _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<ProductState> emit,
  ) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final category = event.category;

      final filtered = category == 'All'
          ? currentState.products
          : currentState.products
              .where((p) => p.category.toLowerCase() == category.toLowerCase())
              .toList();

      // Also respect active search query if any
      final searchFiltered = currentState.searchQuery.isEmpty
          ? filtered
          : filtered
              .where((p) => p.title.toLowerCase().contains(currentState.searchQuery.toLowerCase()))
              .toList();

      emit(currentState.copyWith(
        selectedCategory: category,
        filteredProducts: searchFiltered,
      ));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<ProductState> emit,
  ) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final query = event.query.toLowerCase().trim();

      var baseList = currentState.selectedCategory == 'All'
          ? currentState.products
          : currentState.products
              .where((p) => p.category.toLowerCase() == currentState.selectedCategory.toLowerCase())
              .toList();

      final searchFiltered = query.isEmpty
          ? baseList
          : baseList
              .where((p) =>
                  p.title.toLowerCase().contains(query) ||
                  p.description.toLowerCase().contains(query))
              .toList();

      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredProducts: searchFiltered,
      ));
    }
  }
}
