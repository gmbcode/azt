import 'package:flutter/material.dart';

import '../../customer_widgets/customer_sfproductcards.dart';

class SearchPage extends StatefulWidget {
  final Function(Product) onAddToCart;
  final Function(Product) onRemoveFromCart;
  final List<Product> cart;

  const SearchPage({
    super.key,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.cart,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SearchMainContent(
        onAddToCart: widget.onAddToCart,
        onRemoveFromCart: widget.onRemoveFromCart,
        cart: widget.cart,
      ),
    );
  }
}

class SearchMainContent extends StatefulWidget {
  final Function(Product) onAddToCart;
  final Function(Product) onRemoveFromCart;
  final List<Product> cart;

  const SearchMainContent({
    super.key,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.cart,
  });

  @override
  State<SearchMainContent> createState() => _SearchMainContentState();
}

class _SearchMainContentState extends State<SearchMainContent> {
  // 1. Add a state variable to hold the search query
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // 2. Filter the global 'productList' based on the search query
    final filteredProducts = productList
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Products for you',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              // 3. Update TextField to listen to changes
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search,
                      color: Color.fromARGB(179, 17, 28, 175)),
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 4. Show a message if no products match, otherwise show GridView
            if (filteredProducts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: Text(
                    "No products found",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                // 5. Use filteredProducts instead of productList
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: filteredProducts[index],
                    onAddToCart: widget.onAddToCart,
                    onRemoveFromCart: widget.onRemoveFromCart,
                    cart: widget.cart,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}