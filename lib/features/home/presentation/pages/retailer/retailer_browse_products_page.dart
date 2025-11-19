import 'package:flutter/material.dart';

import '../../../data/retailer_repo.dart';
import '../../retailer_models/retailer_product_model.dart';
import '../../retailer_widgets/retailer_product_card.dart';
import '../../retailer_widgets/retailer_main_sidebar.dart';
import '../../retailer_widgets/retailer_reusable_search_bar.dart';
import '../../retailer_widgets/retailer_status_filter_chips.dart';

class RetailerBrowseProductsPage extends StatefulWidget {
  const RetailerBrowseProductsPage({super.key});

  @override
  State<RetailerBrowseProductsPage> createState() => _RetailerBrowseProductsPageState();
}

class _RetailerBrowseProductsPageState extends State<RetailerBrowseProductsPage> {
  // --- STATE ---
  final RetailerRepository _repo = RetailerRepository();
  bool _isLoading = true;
  
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    
    // FETCH FROM API
    final products = await _repo.getGlobalProducts();

    if (mounted) {
      setState(() {
        _allProducts = products;
        // Generate categories dynamically from the data
        _categories = ['All', ...products.map((p) => p.category).toSet()];
        _filteredProducts = _allProducts; // Initial filter
        _isLoading = false;
      });
    }
  }

  void _filterAndSearch() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final bool matchesCategory = _selectedCategory == 'All' ||
            product.category == _selectedCategory;
        final bool matchesSearch = _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() { _selectedCategory = category; });
    _filterAndSearch();
  }

  void _onSearchChanged(String query) {
    setState(() { _searchQuery = query; });
    _filterAndSearch();
  }

  void _onAddToCart(ProductModel product) {
    // TODO: Implement actual cart logic (e.g. using a CartCubit)
    print("Added to cart: ${product.name}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Row(
        children: [
          // --- Sidebar ---
          const RetailerMainSidebar(selectedPage: 'browse_products'),

          // --- Main Content ---
          Expanded(
            child: _isLoading 
             ? const Center(child: CircularProgressIndicator()) 
             : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header & Filters ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                       color: Colors.white, 
                       borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Browse Products',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ReusableSearchBar(
                                hintText: 'Search products by name...',
                                onChanged: _onSearchChanged,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: StatusFilterChips(
                            filters: _categories,
                            selectedFilter: _selectedCategory,
                            onSelected: _onCategorySelected,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24), 

                  // --- Product Grid ---
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(0), 
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300, 
                        mainAxisSpacing: 20, 
                        crossAxisSpacing: 20, 
                        childAspectRatio: 0.7, 
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return ProductCard(
                          product: product,
                          onAddToCart: () => _onAddToCart(product),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}