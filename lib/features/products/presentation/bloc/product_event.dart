import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final int page;
  final int limit;

  const LoadProducts({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class LoadProductDetail extends ProductEvent {
  final String productId;

  const LoadProductDetail(this.productId);

  @override
  List<Object?> get props => [productId];
}

class SearchProducts extends ProductEvent {
  final String keyword;

  const SearchProducts(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class FilterProductsByCategory extends ProductEvent {
  final String categoryId;

  const FilterProductsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class LoadCategories extends ProductEvent {
  const LoadCategories();
}

class ClearSearch extends ProductEvent {
  const ClearSearch();
}
