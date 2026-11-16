import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends ProductEvent {
  final bool isRefresh;
  const FetchProductsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FilterByCategoryEvent extends ProductEvent {
  final String category;
  const FilterByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchQueryChangedEvent extends ProductEvent {
  final String query;
  const SearchQueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}
