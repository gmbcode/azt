import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../customer/presentation/cubits/customer_cubit.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../auth/presentation/cubits/auth_states.dart';
import '../../customer_widgets/customer_product_card.dart';

class CustomerDashboardPage extends StatelessWidget {
  final Function(String) onNavigate;
  const CustomerDashboardPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // Get User Name
    String username = "Shopper";
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) username = authState.user.name;

    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) return const Center(child: CircularProgressIndicator());
        
        // Data Preparation
        final products = (state is CustomerLoaded) ? state.products : [];
        final categories = (state is CustomerLoaded) 
            ? state.products.map((e) => e.category).toSet().toList() 
            : <String>[];
        
        final featuredProduct = products.isNotEmpty ? products.first : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Text("Good day for shopping,", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              const SizedBox(height: 4),
              Text(username, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 24),

              // 2. Wallet / Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A), 
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Your Cart Total", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        BlocBuilder<CustomerCubit, CustomerState>(
                          builder: (context, state) {
                            double total = 0;
                            if (state is CustomerLoaded) {
                              total = state.cart.fold(0, (sum, item) => sum + (item.price * item.qty));
                            }
                            // Currency Fix
                            return Text("₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900));
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => onNavigate('cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.arrow_forward),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 3. Popular Categories (Functioning Buttons)
              const Text("Popular Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 100, // Increased height slightly to prevent clip
                child: categories.isEmpty 
                ? const Text("No categories yet", style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: InkWell(
                          // Functioning Button: Navigate to browse
                          onTap: () => onNavigate('browse'),
                          borderRadius: BorderRadius.circular(30),
                          child: Column(
                            children: [
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white, 
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  cat.isNotEmpty ? cat[0].toUpperCase() : '?', 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black)
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(cat, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ),

              const SizedBox(height: 30),

              // 4. Hero Banner
              if (featuredProduct != null)
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 24, top: 40,
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.star, color: Colors.grey[300], size: 30),
                              const SizedBox(height: 20),
                              const Text(
                                "PICK OF\nTHE WEEK",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () => onNavigate('browse'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF121212),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  minimumSize: const Size(80, 36),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: const Text("Shop", style: TextStyle(fontSize: 12)),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: -20, top: 10, bottom: 10,
                        width: 200,
                        child: Image.network(
                          featuredProduct.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_,__,___) => const Icon(Icons.shopping_bag, size: 100, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // 5. Grid (New Arrivals) - Fixed Overflow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("New Arrivals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => onNavigate('browse'), 
                    child: const Text("See all")
                  )
                ],
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, 
                  childAspectRatio: 0.6,  // FIXED: Taller aspect ratio prevents overflow
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: products.take(4).length, 
                itemBuilder: (context, index) {
                  final product = products[index];
                  return CustomerProductCard(
                    product: product, 
                    onAdd: () {
                      context.read<CustomerCubit>().addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Added to cart"), duration: Duration(milliseconds: 500))
                      );
                    }
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}