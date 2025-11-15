// lib/pages/retailer_browse_products_page.dart

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../widgets/retailer_main_sidebar.dart';
import '../widgets/reusable_search_bar.dart';
import '../widgets/status_filter_chips.dart';
// --- UPDATED IMPORTS ---
// We are removing the table and adding the card
import '../widgets/product_card.dart';
import '../widgets/responsive_layout.dart'; 

class RetailerBrowseProductsPage extends StatefulWidget {
  const RetailerBrowseProductsPage({super.key});

  @override
  State<RetailerBrowseProductsPage> createState() => _RetailerBrowseProductsPageState();
}

class _RetailerBrowseProductsPageState extends State<RetailerBrowseProductsPage> {
  // --- STATE (Unchanged) ---
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

  // --- All internal logic (fetch, filter, search) is unchanged ---
  void _fetchProducts() {
    final List<ProductModel> dummyProducts = [
      ProductModel(
        id: 'prod1', category: 'Fruits', description: 'Fresh and organic apples.',
        imageUrl: 'https://placehold.co/400x400/a_green/fff?text=Apples',
        name: 'Apples', price: 80.0, stockremain: 45,
      ),
      ProductModel(
        id: 'prod2', category: 'Vegetables', description: 'Locally sourced carrots.',
        imageUrl: 'https://placehold.co/400x400/orange/fff?text=Carrots',
        name: 'Carrots', price: 75.0, stockremain: 75,
      ),
      ProductModel(
        id: 'prod3', category: 'Bakery', description: 'Freshly baked organic bread.',
        imageUrl: 'https://placehold.co/400x400/brown/fff?text=Bread',
        name: 'Organic Bread', price: 50.0, stockremain: 120,
      ),
      ProductModel(
        id: 'prod4', category: 'Pantry', description: 'Extra virgin olive oil.',
        imageUrl: 'https://placehold.co/400x400/olive/fff?text=Olive+Oil',
        name: 'Olive Oil 5L', price: 1500.0, stockremain: 20,
      ),
    ];
    setState(() {
      _allProducts = dummyProducts;
      _categories = ['All', ...dummyProducts.map((p) => p.category).toSet()];
      _filteredProducts = _allProducts;
    });
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
    final bool mobile = isMobile(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: mobile ? AppBar(
        title: const Text('Browse Products'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ) : null,
      drawer: mobile ? const Drawer(
        child: RetailerMainSidebar(selectedPage: 'browse_products'),
      ) : null,
      body: Row(
        children: [
          // --- Sidebar (Desktop only) ---
          if (!mobile)
            const RetailerMainSidebar(selectedPage: 'browse_products'),

          // --- Main Content ---
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(mobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header & Filters (Top white box) ---
                  Container(
                    padding: EdgeInsets.all(mobile ? 16 : 24),
                    decoration: BoxDecoration(
                       color: Colors.white, 
                       borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!mobile)
                          const Text(
                            'Browse Products',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        if (!mobile)
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
                            // TODO: Add a "View Cart" button here
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

                  SizedBox(height: mobile ? 16 : 24),

                  // --- Product Grid ---
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(0),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: mobile ? 200 : 300,
                        mainAxisSpacing: mobile ? 12 : 20,
                        crossAxisSpacing: mobile ? 12 : 20,
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