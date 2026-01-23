import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/core/const/app_images.dart';
import '../../../core/theme/app_colors.dart';
import '../../products/data/models/category_model.dart';
import '../../products/data/models/product_model.dart';
import '../../products/presentation/bloc/product_bloc.dart';
import '../../products/presentation/bloc/product_event.dart';
import '../../products/presentation/bloc/product_state.dart';
import '../widgets/product_card.dart';
import 'all_products_page.dart';
import '../../../core/widgets/shimmer_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  String? _selectedCategoryId;
  // Cache last successful load so UI can show data when bloc is in other states
  List<ProductModel> _cachedProducts = [];
  List<CategoryModel> _cachedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    context.read<ProductBloc>().add(const LoadProducts());
  }

  Future<void> _onRefresh() async {
    _loadProducts();

    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      context.read<ProductBloc>().add(SearchProducts(query));
    } else {
      // clear search -> restore previous product list
      context.read<ProductBloc>().add(const ClearSearch());
    }
  }

  void _onCategoryTap(String categoryId) {
    setState(() {
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null; // clear selection
      } else {
        _selectedCategoryId = categoryId;
      }
    });

    if (_selectedCategoryId == null) {
      context.read<ProductBloc>().add(const LoadProducts());
    } else {
      context.read<ProductBloc>().add(FilterProductsByCategory(_selectedCategoryId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            _searchBar(),


            // Content
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  final bool isSearchingState = state is ProductSearching;
                  final bool isLoadingState = state is ProductLoading;

                  // If we're actively searching, show the shimmer loader.
                  if (isSearchingState) {
                    return Center(child: ShimmerLoader.rect(width: double.infinity, height: 300));
                  }

                  // If loading but the search field is empty and we have cached products,
                  // show cached products immediately while the background reload runs.
                  if (isLoadingState && _searchController.text.isEmpty && _cachedProducts.isNotEmpty) {
                    // use cached products and categories
                    // create a faux ProductLoaded view by setting local lists below
                  } else if (isLoadingState) {
                    // First-time load: show a simple spinner rather than the shimmer loader
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ProductError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<ProductBloc>()
                                  .add(const LoadProducts());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  List<ProductModel> products = [];
                  List<CategoryModel> categories = [];

                  if (state is ProductLoaded) {
                    products = state.products;
                    categories = state.categories;
                    // update cache
                    _cachedProducts = List<ProductModel>.from(state.products);
                    _cachedCategories = List<CategoryModel>.from(state.categories);
                  } else if (state is ProductSearchLoaded) {
                    products = state.products;
                    // keep categories from cache while searching
                    categories = _cachedCategories;
                    // don't overwrite cache with search results
                  } else if (state is ProductDetailLoaded) {
                    // when viewing product detail state is ProductDetailLoaded in the bloc.
                    // Keep showing the last cached products/categories instead of clearing them.
                    products = _cachedProducts;
                    categories = _cachedCategories;
                  } else if (isLoadingState && _searchController.text.isEmpty && _cachedProducts.isNotEmpty) {
                    // Use cache while loading
                    products = _cachedProducts;
                    categories = _cachedCategories;
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Categories Section
                          if (state is ProductLoaded &&
                              categories.isNotEmpty) ...[
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Categories',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const AllProductsPage(),
                                            ),
                                          );
                                        },
                                        child: const Text('See all'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 90,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:  categories.length,
                                      itemBuilder: (context, index) {
                                        final category = categories[index];
                                        final isSelected = _selectedCategoryId == category.id;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: _buildCategoryItem(category, isSelected: isSelected),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // New Arrivals Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      state is ProductSearchLoaded
                                          ? 'Search Results'
                                          : 'New Arrivals',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (state is! ProductSearchLoaded)
                                      IconButton(
                                        icon: const Icon(Icons.tune),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const AllProductsPage(),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                products.isEmpty
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(32.0),
                                          child: Text('No products found'),
                                        ),
                                      )
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.7,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                        ),
                                        itemCount: products.length > 6
                                            ? 6
                                            : products.length,
                                        itemBuilder: (context, index) {
                                          return ProductCard(
                                            product: products[index],
                                            isHighlighted: index == 0,
                                          );
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom bar wrapped in a white container with a subtle top shadow
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            // Negative offset makes the shadow appear above the bar
            BoxShadow(
              color: Color.fromRGBO(128, 128, 128, 0.22),
              offset: const Offset(0, -4),
              blurRadius: 8,
            ),
          ],
        ),
        // SafeArea keeps the bar above system UI (gestures/indicator)
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.transparent,
            elevation: 0,
            items:  [
              BottomNavigationBarItem(
                icon: Image.asset(
                  AppImages.homeIcon,
                  width: 24,
                  height: 24,
                ),
                activeIcon: Image.asset(
                  AppImages.homeIcon,
                  width: 24,
                  height: 24,
                  color: AppColors.primary,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  AppImages.messageIcon,
                  width: 24,
                  height: 24,
                ),
                activeIcon: Image.asset(
                  AppImages.messageIcon,
                  width: 24,
                  height: 24,
                  color: AppColors.primary,
                ),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  AppImages.orderIcon,
                  width: 24,
                  height: 24,
                ),
                activeIcon: Image.asset(
                  AppImages.orderIcon,
                  width: 24,
                  height: 24,
                  color: AppColors.primary,
                ),
                label: 'Order',
              ),

              BottomNavigationBarItem(
                icon: Image.asset(
                  AppImages.profileIcon,
                  width: 24,
                  height: 24,
                ),
                activeIcon: Image.asset(
                  AppImages.profileIcon,
                  width: 24,
                  height: 24,
                  color: AppColors.primary,
                ),
                label: 'Profile',
              ),

            ],
          ),
        ),
      ),

    );
  }

  Widget _searchBar(){
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: const InputDecoration(
                hintText: 'Search products',
                hintStyle: TextStyle(color: AppColors.lightGrey),
                prefixIcon:
                Icon(Icons.search, color: AppColors.lightGrey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel category, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _onCategoryTap(category.id),
      child: Column(
        children: [
        Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(12),
        decoration:  BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primaryLight,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: AppColors.primaryDark, width: 2) : null,
        ),
        child: category.image?.isNotEmpty == true
            ? ClipRRect(
              child: CachedNetworkImage(
                imageUrl:
                "https://mamunuiux.com/flutter_task/${category.image}",
                fit: BoxFit.scaleDown,
                placeholder: (_, __) => Center(child: ShimmerLoader.circle(size: 36)),
                errorWidget: (_, __, ___) =>
                const Icon(Icons.image_not_supported, color: Colors.white),
              ),
            )
            : const Icon(Icons.image_not_supported, color: Colors.white),
            ),

        const SizedBox(height: 6),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
