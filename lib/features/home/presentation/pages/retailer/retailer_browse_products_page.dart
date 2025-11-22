import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';
import 'retailer_cart_page.dart';

class RetailerBrowseProductsPage extends StatefulWidget {
  const RetailerBrowseProductsPage({super.key});
  @override
  State<RetailerBrowseProductsPage> createState() => _RetailerBrowseProductsPageState();
}

class _RetailerBrowseProductsPageState extends State<RetailerBrowseProductsPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetailerCubit, RetailerState>(
      builder: (context, state) {
        if (state is RetailerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is RetailerLoaded) {
          final products = state.wholesalerListings.where((p) => 
             p.name.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

          final Map<String, int> cartCounts = {};
          for (var item in state.cartItems) {
            cartCounts[item['id']] = item['qty'];
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(color: Colors.black87), 
                        decoration: InputDecoration(
                          hintText: "Search products...",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (MediaQuery.of(context).size.width > 800)
                      FloatingActionButton.extended(
                        onPressed: () {
                          final retailerCubit = context.read<RetailerCubit>();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: retailerCubit, child: const RetailerCartPage())));
                        },
                        label: Text("Cart (${state.cartItems.length})"),
                        icon: const Icon(Icons.shopping_cart),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: products.isEmpty 
                  ? Center(child: Text("No products found", style: TextStyle(color: Colors.grey[600])))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final int inCartQty = cartCounts[product.id] ?? 0;
                        
                        // FIXED: Validation logic
                        final bool isMaxReached = inCartQty >= product.availableQty;
                        final bool isOutOfStock = product.availableQty == 0;

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey[200], child: const Icon(Icons.image))),
                                    if (inCartQty > 0)
                                      Positioned(
                                        top: 8, right: 8,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.orange,
                                          radius: 14,
                                          child: Text("$inCartQty", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                        ),
                                      )
                                  ],
                                )
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Rupee Symbol Fix
                                        Text('₹${product.price}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                        Text('Stock: ${product.availableQty}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 36,
                                      child: ElevatedButton(
                                        // FIXED: Disable button if max reached or out of stock
                                        onPressed: (isMaxReached || isOutOfStock)
                                            ? null 
                                            : () => context.read<RetailerCubit>().addToCart(product),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: (isMaxReached || isOutOfStock) ? Colors.grey : null,
                                        ),
                                        child: Text(
                                          isOutOfStock 
                                            ? "Out of Stock" 
                                            : (isMaxReached ? "Max Limit" : "Add to Cart"),
                                          style: TextStyle(fontSize: 12, color: (isMaxReached || isOutOfStock) ? Colors.white : null)
                                        ),
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