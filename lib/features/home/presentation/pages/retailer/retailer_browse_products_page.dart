import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';
import '../../retailer_widgets/retailer_reusable_search_bar.dart';
import 'retailer_cart_page.dart';

class RetailerBrowseProductsPage extends StatefulWidget {
  const RetailerBrowseProductsPage({super.key});
  @override
  State<RetailerBrowseProductsPage> createState() => _RetailerBrowseProductsPageState();
}

class _RetailerBrowseProductsPageState extends State<RetailerBrowseProductsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetailerCubit, RetailerState>(
      builder: (context, state) {
        if (state is RetailerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is RetailerLoaded) {
          final products = state.wholesalerListings.where((p) => 
             p.name.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(
                        child: ReusableSearchBar(
                          hintText: 'Search products...',
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // --- CART BUTTON (FIXED) ---
                      ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_cart),
                        label: Text('Cart (${state.cartItems.length})'),
                        onPressed: () {
                          // 1. Capture the existing cubit from the current context
                          final retailerCubit = context.read<RetailerCubit>();
                          
                          // 2. Navigate, wrapping the destination in BlocProvider.value
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: retailerCubit, // Pass the EXISTING cubit instance
                                child: const RetailerCartPage(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.network(
                                product.imageUrl, 
                                fit: BoxFit.cover, 
                                width: double.infinity,
                                errorBuilder: (_,__,___) => Container(color: Colors.grey[300], child: const Icon(Icons.image)),
                              )
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('\$${product.price}', style: const TextStyle(color: Colors.green)),
                                  Text('Avail: ${product.availableQty}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => context.read<RetailerCubit>().addToCart(product),
                                      child: const Text("Add to Cart"),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}