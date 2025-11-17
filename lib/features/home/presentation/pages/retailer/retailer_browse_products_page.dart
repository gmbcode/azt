// lib/pages/retailer_browse_products_page.dart

import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Row(
        children: [
          // --- Sidebar ---
          const RetailerMainSidebar(selectedPage: 'browse_products'),

          // --- Main Content ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header & Filters (Top white box) ---
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

                  const SizedBox(height: 24), // Space between boxes

                  // --- *** THIS IS THE NEW GRID LAYOUT *** ---
                  //
                  // This Expanded widget forces the grid to fill
                  // all the remaining empty space.
                  //
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(0), // No padding needed, grid handles it
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300, // Max width for each card
                        mainAxisSpacing: 20, // Space between rows
                        crossAxisSpacing: 20, // Space between columns
                        childAspectRatio: 0.7, // Taller cards (height > width)
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        // Use the new ProductCard widget
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