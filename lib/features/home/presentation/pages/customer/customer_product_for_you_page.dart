import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../customer/presentation/cubits/customer_cubit.dart';
import '../../customer_widgets/customer_product_card.dart';

class CustomerProductsForYouPage extends StatelessWidget {
  const CustomerProductsForYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is CustomerLoaded) {
          // We use the FILTERED list here
          final localProducts = state.productsForYou;

          if (localProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  const Text(
                    "No products found in your area.",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Try updating your pincode or check back later.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 10),
                child: Text(
                  "Products Near You", 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Curated from retailers in your pincode",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220, 
                    childAspectRatio: 0.6,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: localProducts.length,
                  itemBuilder: (context, index) {
                    final product = localProducts[index];
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