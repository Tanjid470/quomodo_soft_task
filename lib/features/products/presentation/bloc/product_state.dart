import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductDetailLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final bool hasReachedMax;

  const ProductLoaded({
    required this.products,
    this.categories = const [],
    this.hasReachedMax = false,
  });

  ProductLoaded copyWith({
    List<ProductModel>? products,
    List<CategoryModel>? categories,
    bool? hasReachedMax,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [products, categories, hasReachedMax];
}

class ProductDetailLoaded extends ProductState {
  final ProductModel product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductSearching extends ProductState {}

class ProductSearchLoaded extends ProductState {
  final List<ProductModel> products;
  final String keyword;

  const ProductSearchLoaded({
    required this.products,
    required this.keyword,
  });

  @override
  List<Object?> get props => [products, keyword];
}
