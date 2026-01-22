import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductDetail>(_onLoadProductDetail);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<LoadCategories>(_onLoadCategories);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final products = await repository.getProducts(
        page: event.page,
        limit: event.limit,
      );
      final categories = await repository.getCategories();
      emit(ProductLoaded(
        products: products,
        categories: categories,
        hasReachedMax: products.length < event.limit,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadProductDetail(
    LoadProductDetail event,
    Emitter<ProductState> emit,
  ) async {
    try {
      // Emit loading only if not already loading product detail
      if (state is! ProductDetailLoading) {
        emit(ProductDetailLoading());
      }
      
      final product = await repository.getProductById(event.productId);
      if (product != null) {
        emit(ProductDetailLoaded(product));
      } else {
        emit(const ProductError('Product not found'));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      if (event.keyword.isEmpty) {
        add(const LoadProducts());
        return;
      }
      emit(ProductSearching());
      
      // Search functionality not available in API, filtering locally
      final allProducts = await repository.getProducts();
      final filteredProducts = allProducts
          .where((product) =>
              product.name.toLowerCase().contains(event.keyword.toLowerCase()) ||
              product.description.toLowerCase().contains(event.keyword.toLowerCase()))
          .toList();
      
      emit(ProductSearchLoaded(
        products: filteredProducts,
        keyword: event.keyword,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onFilterProductsByCategory(
    FilterProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final products = await repository.getProductsByCategory(event.categoryId);

      List<CategoryModel> categories = [];
      if (state is ProductLoaded) {
        categories = (state as ProductLoaded).categories;
      } else {
        categories = await repository.getCategories();
      }

      emit(ProductLoaded(
        products: products,
        categories: categories,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final categories = await repository.getCategories();
      if (state is ProductLoaded) {
        emit((state as ProductLoaded).copyWith(categories: categories));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<ProductState> emit,
  ) async {
    add(const LoadProducts());
  }
}
