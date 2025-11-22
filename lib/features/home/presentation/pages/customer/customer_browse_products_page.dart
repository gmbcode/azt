import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../customer/presentation/cubits/customer_cubit.dart';
import '../../customer_widgets/customer_product_card.dart';

class CustomerBrowseProductsPage extends StatefulWidget {
  const CustomerBrowseProductsPage({super.key});

  @override
  State<CustomerBrowseProductsPage> createState() => _CustomerBrowseProductsPageState();
}

class _CustomerBrowseProductsPageState extends State<CustomerBrowseProductsPage> {
  String _search = "";
  String _category = "All";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is CustomerLoaded) {
          final categories = ["All", ...state.products.map((e) => e.category).toSet().toList()];
          
          final filtered = state.products.where((p) {
            final matchesSearch = p.name.toLowerCase().contains(_search.toLowerCase());
            final matchesCategory = _category == "All" || p.category == _category;
            return matchesSearch && matchesCategory;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.isNotEmpty 
                          ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _search = '')) 
                          : null,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = _category == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ActionChip(
                              label: Text(cat),
                              backgroundColor: isSelected ? Colors.white : Colors.transparent,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.black : Colors.grey,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : Colors.grey.shade800,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              onPressed: () => setState(() => _category = cat),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Search Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("${filtered.length} found", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filtered.isEmpty 
                ? Center(child: Text("No products found.", style: TextStyle(color: Colors.grey.shade700)))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220, 
                      childAspectRatio: 0.6, // FIXED
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return CustomerProductCard(
                        product: product,
                        onAdd: () {
                          context.read<CustomerCubit>().addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Added to cart"), duration: Duration(milliseconds: 500))
                          );
                        },
                      );
                    },
                  ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}