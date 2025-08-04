import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../data/mock_products.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import '../widgets/category_filter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _products = MockProducts.getProducts();
    _filteredProducts = _products;
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedCategory == 'All' || 
                              product.category == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty ||
                            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            product.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterProducts();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartMart'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () {
              // TODO: Implement QR/Barcode scanner
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('QR Scanner coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                filled: true,
                fillColor: AppColors.backgroundWhite,
              ),
            ),
          ),

          // Category Filter
          CategoryFilter(
            categories: ['All', ...MockProducts.getCategories()],
            selectedCategory: _selectedCategory,
            onCategoryChanged: _onCategoryChanged,
          ),

          // Products Grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: AppSizes.paddingMedium),
                        Text(
                          'No products found',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: AppSizes.paddingSmall),
                        Text(
                          'Try adjusting your search or category filter',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(AppSizes.paddingMedium),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: AppSizes.paddingMedium,
                      mainAxisSpacing: AppSizes.paddingMedium,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: _filteredProducts[index],
                        onAddToCart: () {
                          context.read<CartProvider>().addItem(_filteredProducts[index]);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${_filteredProducts[index].name} added to cart'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 