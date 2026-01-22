import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
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

      // If user pasted a full product URL, extract slug part
      String keyword = event.keyword.trim();
      try {
        final uri = Uri.tryParse(keyword);
        if (uri != null && uri.path.isNotEmpty && keyword.contains('/product/')) {
          final segments = uri.path.split('/');
          final idx = segments.indexWhere((s) => s == 'product');
          if (idx != -1 && idx + 1 < segments.length) {
            keyword = segments.sublist(idx + 1).join('/');
          } else {
            keyword = segments.last;
          }
        }
      } catch (_) {}

      // Reuse already-loaded products if available to avoid extra network call
      final List<ProductModel> allProducts = state is ProductLoaded
          ? List<ProductModel>.from((state as ProductLoaded).products)
          : await repository.getProducts();

      final List<ProductModel> filteredProducts = allProducts
          .where((product) {
            final q = keyword.toLowerCase();
            return product.name.toLowerCase().contains(q) ||
                product.description.toLowerCase().contains(q) ||
                product.slug.toLowerCase().contains(q);
          })
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
      // Preserve existing categories so the UI can keep showing them
      List<CategoryModel> categories = [];
      if (state is ProductLoaded) {
        categories = List<CategoryModel>.from((state as ProductLoaded).categories);
      }

      // Fetch filtered products without switching the UI to ProductLoading()
      final products = await repository.getProductsByCategory(event.categoryId);

      // If we didn't have categories cached, try fetching them
      if (categories.isEmpty) {
        try {
          categories = await repository.getCategories();
        } catch (_) {
          // If fetching categories fails, keep categories empty but don't crash
        }
      }

      // Emit ProductLoaded with new products and preserved categories
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
